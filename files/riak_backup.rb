#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'aws-sdk'
require 'facter'
require 'optparse'
require 'logging'

# Take care of options
options = { :days => 0 }
OptionParser.new do |opts|
  opts.banner = "Usage: riak_prod.rb -m mode"
  opts.on('-m', '--mode MODE', 'Backup mode') { |v| options[:mode] = v }
  opts.on('-d', '--days DAYS', 'Maximum number of days of snapshots to keep') { |v| options[:days] = v.to_i }
  opts.on('-h', '--help', 'Help') { puts opts ; exit }
end.parse!

raise OptionParser::MissingArgument, '-m is required' if options[:mode].nil?
raise OptionParser::InvalidOption, 'Valid mode options are snapshot and copy' if !['snapshot', 'copy'].include?options[:mode]
raise OptionParser::InvalidOption, 'Rentention days must be a positive integer' if !options[:days].is_a?(Integer) || options[:days] <= 0

def stop_riak
  @log.info "Stopping riak..."
  output = `/etc/init.d/riak stop`
  exitstatus = $?.exitstatus
  if exitstatus > 0
    raise "Riak failed to successfully stop"
  else
    @log.info "Riak stopped"
  end
end

def start_riak
  @log.info "Checking if riak is running..."
  output = `/etc/init.d/riak status`
  if $?.exitstatus == 0
    @log.info "Riak already running"
  else
    @log.info "Starting riak..."
    output = `/etc/init.d/riak start`
    if $?.exitstatus != 0
      raise "Riak failed to successfully start"
    else
      @log.info "Riak started"
    end
  end
end

def create_snapshot ec2
  AWS.start_memoizing

  hostname = Facter.hostname
  node = ec2.instances[Facter.ec2_instance_id_cached]
  volumes = node.attachments
  if volumes.length != 1
    raise "Script only handles single EBS volume attachments for backups.  Improve me!"
  end

  # This only works because we have one key
  volume = ''
  volumes.each_key do |vol|
    volume = volumes[vol].volume
  end

  @log.info "Creating snapshot of volume #{volume.id}"

  snapshot = volume.create_snapshot("#{hostname} - #{volume.id} - #{Time.now.to_s}")
  snapshot.tags["Name"] = "#{hostname}"
  snapshot.tags['type'] = 'riak'
  snapshot.tags['purge'] = true

  # Need to fetch snapshot progress
  AWS.stop_memoizing

  while ![:completed, :error].include?(snapshot.status)
    sleep 5
 end

 if snapshot.status == :completed
    @log.info "Snapshot completed (#{snapshot.id})"
 else
    raise "Snapshot failed"
 end
end

def clean_snapshots ec2, days
  @log.info "Looking for snapshots to clean up..."
  threshold = Time.now - (60 * 60 * 24 * days)
  snapshots = ec2.snapshots.with_owner(:self)

  snapshots.map do |snap|
    if snap.start_time < threshold and snap.tags["purge"] == "true" and snap.tags['type'] == 'riak' and snap.tags['Name'] == Facter.hostname
      @log.info "Deleting #{snap}..."

      begin
#        snap.delete
@log.info "Would delete #{snap.id}"
      rescue => exception
        @log.error exception
        next
      end
    end
  end
end

def copy_data
  fail = false
  @log.info "Creating archive..."
  if !File.exists?("#{@config[:tmp_dir]}/riak")
    Dir.mkdir("#{@config[:tmp_dir]}/riak")
  end

  output = `rm -rf #{@config[:tmp_dir]}/riak/*`
  if $?.exitstatus != 0
    raise "Could not clean destination directory"
  end

  output = `cp -a /var/lib/riak #{@config[:tmp_dir]}/riak/riak_data`
  if $?.exitstatus != 0
    fail = true
    @log.error "Copy of /var/lib/riak failed"
    @log.error output
  end
  output = `cp -a /etc/riak #{@config[:tmp_dir]}/riak/riak_etc`
  if $?.exitstatus != 0
    fail = true
    @log.error "Copy of /etc/riak failed"
    @log.error output
  end

  if fail
    raise "Copy process did not complete properly"
  end
end

# Load config and test to make sure keys are all present
if !File.exists?('/etc/riak/backups.yaml')
  raise "Config file (/etc/riak/backups.yaml) does not exist"
end
@config = YAML.load(File.read("/etc/riak/backups.yaml"))

# If the config file is blank, create a hash to move to the needed config errors
if !@config.is_a?(Hash)
  @config = {}
end

[:access_key_id, :secret_access_key, :region, :tmp_dir, :logfile].each do |key|
  raise ":#{key} not present in config file}" if !@config.has_key?(key)
end

# Logging
Logging.backtrace true
Logging.format_as :json
Logging.logger.root.appenders = Logging.appenders.rolling_file( @config[:logfile],
  :roll_by  => 'date',
  :age      => 'weekly',
  :layout   => Logging.layouts.json
)
@log = Logging.logger['riak_backup']

# Set up AWS
AWS.config(
  :access_key_id      => @config[:access_key_id],
  :secret_access_key  => @config[:secret_access_key]
)
ec2 = AWS::EC2.new
ec2 = ec2.regions[@config[:region]]

begin
  case options[:mode]
  when 'snapshot'
    stop_riak
    create_snapshot ec2
    start_riak
    if options[:days] > 0
      AWS.memoize { clean_snapshots ec2, options[:days] }
    end
  when 'copy'
    stop_riak
    copy_data
    start_riak
  end
rescue => exception
  # Try to always make sure riak is running at the end
  @log.error "#{exception.message} (#{exception.class})"
  @log.error exception.backtrace.join("\n")
  @log.error "Trying to leave riak in a happy state..."
  start_riak
end
@log.info "Backup finished"
