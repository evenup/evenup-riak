require 'spec_helper'

describe 'riak::cluster', :type => :class do

  it { should create_class('riak::cluster') }
  it { should contain_file('/etc/facts.d/riak_cluster.txt')}

end
