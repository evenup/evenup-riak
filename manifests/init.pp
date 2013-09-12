# == Class: redis
#
# This class installs and redis on RHEL based machines
#
#
# === Examples
#
# * Installation:
#     class { 'riak': }
#
#
# === Parameters
#
# [*version*]
#   String.  Version of Riak to install.
#   Default: undef
#
# [*autoupgrade*]
#   Boolean. Allow auto upgrading the riak package
#   Default: false
#
# [*backup_script*]
#   Boolean.  Whether or not the backup script should be installed
#   Default: false
#
# [*backup_tar_cron*]
#   Boolean.  Should a cron script be installed for the tar backups?
#   Default: false
#
# [*backup_tar_cron_minute*]
#   Integer.  Minute for tar backup script
#   Default: 0
#
# [*backup_tar_cron_hour*]
#   Integer.  Hour for tar backup script
#   Default: 0
#
# [*backup_tar_cron_day*]
#   Integer.  Day for tar backup script
#   Default: 0
#
# [*backup_snap_cron*]
#   Boolean.  Should a cron script be installed for the snapshot backups?
#   Default: false
#
# [*backup_snap_cron_minute*]
#   Integer.  Minute for snapshot backup script
#   Default: 0
#
# [*backup_snap_cron_hour*]
#   Integer.  Hour for snapshot backup script
#   Default: 0
#
# [*backup_snap_cron_day*]
#   Integer.  Day for snapshot backup script
#   Default: 0
#
# [*backup_snap_keep_days*]
#   Integer.  Number of backup snapshots to keep.
#   Default: 10
#
# [*cluster_name*]
#   String.  Name of the riak cluster
#   Default:  riak
#
# [*pb_ip*]
#   String.  IP for the PB interface to listen on
#   Default: 0.0.0.0
#
# [*pb_port*]
#   Integer.  Port to listen on
#   Default: 8087
#
# [*ring_state_dir*]
#   String. Directory to store ring state
#   Default: '/var/lib/riak/ring'
#
# [*ring_creation_size*]
#   Integer.  Size of the riak ring
#   Default: 64
#
# [*http_ip*]
#   String.  IP for the HTTP interface to listen on
#   Default 0.0.0.0
#
# [*http_port*]
#   Integer.  Port for the http interface to listen on
#   Default: 8098
#
# [*handoff_port*]
#   Integer.  Port for the handoff interface to listen on
#   Default: 8099
#
# [*dtrace_support*]
#   Boolean.  Include dtrace support
#   Default: false
#
# [*storage_backend*]
#   String.  Backend to use
#   Default: 'riak_kv_multi_backend
#
# [*anti_entropy*]
#   String.  Anti-entropy setting
#   Default: on
#
# [*anti_entropy_build_limit*]
#   String.  AAE Setting
#   Default: 1, 3600000
#
# [*anti_entropy_expire*]
#   Integer.  AAE Expire
#   Default:  604800000
#
# [*anti_entropy_concurrency*]
#   Integer.  AAE concurrency
#   Default: 2
#
# [*anti_entropy_tick*]
#   Integer.  AAE tick
#   Default: 15000
#
# [*anti_entropy_data_dir*]
#   String.  Data directory
#   Default: /var/lib/riak/anti_entropy
#
# [*search_enabled*]
#   Boolean.  Enable search
#   Default: false
#
# [*merge_index_data_root*]
#   String.  Location for index dir
#   Default: /var/lib/riak/merge_index
#
# [*buffer_rollover_size*]
#   Integer.  Buffer rollover size
#   Default:  1048576
#
# [*max_compact_segments*]
#   Integer.  Compact segments
#   Default: 20
#
# [*bitcask_data_root*]
#   String.  Bitcask data dir
#   Default: /var/lib/riak/bitcask
#
# [*eleveldb_data_root*]
#   String.  LevelDB dir
#   Default: /var/lib/riak/leveldb
#
# [*riak_control_enabled*]
#   Boolean.  Enable riak control
#   Default: false
#
# [*inet_dist_listen_min*]
#   Integer.  Minimmum listen port
#   Default: 6000
#
# [*inet_dist_listen_max*]
#   Integer.  Maximum listen port
#   Default: 7999
#
# [*node_name*]
#   String.  Name for this node
#   Default: riak@${::fqdn}
#
# [*cookie*]
#   String.  Riak cookie to use
#   Default: riak
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riak (
  $version                  = undef,
  $autoupgrade              = false,
  # backups
  $backup_script            = false,
  $backup_tar_cron          = false,
  $backup_tar_cron_hour     = 0,
  $backup_tar_cron_minute   = 0,
  $backup_tar_cron_day      = 0,
  $backup_snap_cron         = false,
  $backup_snap_cron_hour    = 0,
  $backup_snap_cron_minute  = 0,
  $backup_snap_cron_day     = 0,
  $backup_snap_keep_days    = 10,
  $cluster_name             = 'riak',
  # app.config settings
  $pb_ip                    = '0.0.0.0',
  $pb_port                  = 8087,
  $ring_state_dir           = '/var/lib/riak/ring',
  $ring_creation_size       = 64,
  $http_ip                  = '0.0.0.0',
  $http_port                = 8098,
  $handoff_port             = 8099,
  $dtrace_support           = false,
  $storage_backend          = 'riak_kv_multi_backend',
  $anti_entropy             = 'on',
  $anti_entropy_build_limit = '1, 3600000',
  $anti_entropy_expire      = 604800000,
  $anti_entropy_concurrency = 2,
  $anti_entropy_tick        = 15000,
  $anti_entropy_data_dir    = '/var/lib/riak/anti_entropy',
  $search_enabled           = false,
  $merge_index_data_root    = '/var/lib/riak/merge_index',
  $buffer_rollover_size     = 1048576,
  $max_compact_segments     = 20,
  $bitcask_data_root        = '/var/lib/riak/bitcask',
  $eleveldb_data_root       = '/var/lib/riak/leveldb',
  $riak_control_enabled     = false,
  $inet_dist_listen_min     = 6000,
  $inet_dist_listen_max     = 7999,
  # vm.args
  $node_name                = '', # Defaults to riak@::fqdn below
  $cookie                   = 'riak',
){

  $node_name_real = $node_name ? {
    ''      => "riak@${::fqdn}",
    default => $name
  }

  class { 'riak::package': }
  class { 'riak::config': }
  class { 'riak::service': }
  class { 'riak::cluster': }

  # Containment
  anchor { 'riak::begin': }
  anchor { 'riak::end': }

  Anchor['riak::begin'] ->
  Class['riak::package'] ->
  Class['riak::config'] ->
  Class['riak::service'] ->
  Class['riak::cluster'] ->
  Anchor['riak::end']

}
