# == Class: pypi
#
# Install and configure a local pypi.
#
# === Requires
#
# puppetlabs-apache
#
# === Parameters
#
# [*pypi_http_password*]
#   Set the password for uploads.
#   Default: '1234'
#
# [*pypi_port*]
#   Port for apache to listen on.
#   Default: 80
#
# === Examples
#
#   include pypi
#
#   class { 'pypi':
#     pypi_http_password => hiera('my_secret_pypi_key'),
#     pypi_port          => '8080',
#   }
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
  $pypi_http_password = '1234',
  $pypi_port = '80',
  ) {
  group { 'pypi':
    ensure => present,
  }
  user { 'pypi':
    ensure  => present,
    gid     => 'pypi',
    home    => '/home/pypi',
    require => Group['pypi'],
  }

  file { [ '/home/pypi', '/var/pypi', '/var/pypi/packages' ]:
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

  exec { 'create-htaccess':
    command => "/usr/bin/htpasswd -sbc /var/pypi/.htaccess pypiadmin ${pypi_http_password}",
    user    => 'pypi',
    group   => 'pypi',
    creates => '/var/pypi/.htaccess',
    require => Package['httpd'],
    notify  => Service['httpd'],
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
