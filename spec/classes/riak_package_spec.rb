require 'spec_helper'

describe 'riak::package', :type => :class do

  it { should create_class('riak::package') }
  it { should contain_file('/etc/init.d/riak') }
  it { should contain_exec('clean_default_riak_configs').with_refreshonly(true) }

  context "version => undef" do
    context "autoupgrade => false" do
      let(:pre_condition) { ["class riak { $version = undef $autoupgrade = false }", "include riak"]}

      it { should contain_package('riak').with_ensure('installed') }
    end

    context "autoupgrade => true" do
      let(:pre_condition) { ["class riak { $version = 'latest' $autoupgrade = true }", "include riak"]}

      it { should contain_package('riak').with_ensure('latest') }
    end
  end

  context "version => '1.3.1'" do
    context "autoupgrade => false" do
      let(:pre_condition) { ["class riak { $version = '1.3.1' $autoupgrade = false }", "include riak"]}

      it { should contain_package('riak').with_ensure('installed') }
    end

    context "autoupgrade => true" do
      let(:pre_condition) { ["class riak { $version = '1.3.1' $autoupgrade = true }", "include riak"]}

      it { should contain_package('riak').with_ensure('1.3.1') }
    end
  end

  context 'backup script' do
    let(:pre_condition) { ["class riak { $backup_script = true }", "include riak"]}

    it { should contain_file('/usr/local/bin/riak_backup.rb') }
  end

  context 'tar backup cron' do
    let(:pre_condition) { ["class riak { $backup_script = true $backup_tar_cron = true }", "include riak"]}

    it { should contain_cron('riak_backup_copy') }
  end

  context 'snapshot backup cron' do
    let(:pre_condition) { ["class riak { $backup_script = true $backup_snap_cron = true }", "include riak"]}

    it { should contain_cron('riak_backup_snapshot') }
  end

end
