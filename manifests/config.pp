# == Class: riak::config
#
# This class manages the riak config
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riak::config (

) {

  file { '/etc/riak/app.config':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    replace => false,
    content => template('riak/app.config.erb'),
    notify  => Class['riak::service'],
  }

  file { '/etc/riak/vm.args':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    replace => false,
    content => template('riak/vm.args.erb'),
    notify  => Class['riak::service'],
  }

}
