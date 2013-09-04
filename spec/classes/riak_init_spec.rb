require 'spec_helper'

describe 'riak', :type => :class do

  it { should create_class('riak') }
  it { should contain_class('riak::package') }
  it { should contain_class('riak::config') }
  it { should contain_class('riak::service') }
  it { should contain_class('riak::cluster') }

end
