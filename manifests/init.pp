# == Class: pypi
#
# Install and configure a local pypi.
#
# === Requires
#
# puppetlabs-apache
#
# === Examples
#
#   include pypi
#
# === Authors
#
# Thomas Van Doren
#
# === Copyright
#
# Copyright 2012 Cozi Group, Inc., unless otherwise noted
#
class pypi (
  $pypi_port = '80',
  ) {
  group { 'pypi':
    ensure => present,
  }
  user { 'pypi':
    ensure  => present,
    gid     => 'pypi',
    require => Group['pypi'],
  }

  file { ['/var/pypi', '/var/pypi/packages']:
    ensure => directory,
    owner  => 'pypi',
    group  => 'pypi',
  }
  file { 'pypiserver_wsgi.py':
    ensure => present,
    path   => '/var/pypi/pypiserver_wsgi.py',
    owner  => 'pypi',
    group  => 'pypi',
    mode   => '0755',
    source => 'puppet:///modules/pypi/pypiserver_wsgi.py',
    notify => Service['httpd'],
  }
  file { '.htaccess':
    ensure => present,
    path   => '/var/pypi/.htaccess',
    owner  => 'pypi',
    group  => 'pypi',
    mode   => '0755',
    source => 'puppet:///modules/pypi/.htaccess',
    notify => Service['httpd'],
  }

  include apache
  include apache::mod::wsgi
  apache::vhost { 'pypi':
    priority      => '10',
    port          => $pypi_port,
    docroot       => '/var/pypi',
    docroot_owner => 'pypi',
    docroot_group => 'pypi',
    template      => 'pypi/vhost-pypi.conf.erb',
  }

  package { 'python-pip':
    ensure => present,
  }
  package { ['passlib', 'pypiserver']:
    ensure   => present,
    provider => 'pip',
    notify   => Service['httpd'],
  }
}
