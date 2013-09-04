require 'spec_helper'

describe 'riak::config', :type => :class do

  it { should create_class('riak::config') }
  it { should contain_file('/etc/riak/app.config') }
  it { should contain_file('/etc/riak/vm.args') }

end
