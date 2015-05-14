# == Class: riak::package
#
# This class manages the riak package
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class riak::package {

  if $riak::version {
    $ensure_real = $riak::autoupgrade ? {
      true    => $riak::version,
      default => 'installed'
    }
  } else {
    $ensure_real = $riak::autoupgrade ? {
      true    => 'latest',
      default => 'installed'
    }
  }

  package {'riak':
    ensure => $ensure_real,
    notify => Exec['clean_default_riak_configs'],
  }

  file { '/etc/init.d/riak':
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    source  => 'puppet:///modules/riak/riak.init',
    require => Package['riak'],
  }

  # riak::config has replace => false set on files so we need to remove
  # the default config files when the riak package is modified to ensure
  # the correct config files are in place
  exec { 'clean_default_riak_configs':
    command     => 'rm -f /etc/riak/vm.args ; rm -f /etc/riak/app.config',
    path        => '/bin',
    refreshonly => true,
  }

}
