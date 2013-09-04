# == Class: riak::cluster
#
# This class manages this node in the cluster
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riak::cluster {

  # Set the riak cluster fact.  Once it is set, do not replace it
  file { '/etc/facts.d/riak_cluster.txt':
    mode    => '0444',
    replace => false,
    content => "riak_cluster=${riak::configure_cluster}\n",
  }

}
