require 'spec_helper'

describe 'riak::service', :type => :class do

  it { should create_class('riak::service') }
  it { should contain_service('riak') }

end
