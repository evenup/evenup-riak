# == Class: riak::service
#
# This class manages the riak service
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riak::service {

  service { 'riak':
    ensure => 'running',
    enable => true,
  }

}
