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
# [*pypi_root*]
#   Directory to install pypi and keep packages.
#   Default: /var/pypi
#
# === Examples
#
#   include pypi
#
#   class { 'pypi':
#     pypi_http_password => hiera('my_secret_pypi_key'),
#     pypi_port          => '8080',
#     pypi_root          => '/srv/pypi',
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
  $pypi_root = '/var/pypi',
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

  file { [ '/home/pypi', $pypi_root, "${pypi_root}/packages" ]:
    ensure => directory,
    owner  => 'pypi',
    group  => 'pypi',
  }
  file { 'pypiserver_wsgi.py':
    ensure  => present,
    path    => "${pypi_root}/pypiserver_wsgi.py",
    owner   => 'pypi',
    group   => 'pypi',
    mode    => '0755',
    content => template('pypi/pypiserver_wsgi.py'),
    notify  => Service['httpd'],
  }

  httpauth { 'pypiadmin':
    ensure    => present,
    file      => "${pypi_root}/.htaccess",
    password  => $pypi_http_password,
    mechanism => 'basic',
    require   => [ Package['httpd'], File[$pypi_root] ],
    notify    => Service['httpd'],
  }

  include apache
  include apache::mod::wsgi
  apache::vhost { 'pypi':
    priority      => '10',
    port          => $pypi_port,
    docroot       => $pypi_root,
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
