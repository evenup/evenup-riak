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

end
