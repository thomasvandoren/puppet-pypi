require 'spec_helper'

describe 'pypi', :type => 'class' do

  context "On Debian system with default params" do

    let :facts do
      {
        :osfamily => 'Debian'
      }
    end # let

    it do
      should contain_group('pypi').with_ensure('present')
      should contain_user('pypi').with(:ensure  => 'present',
                                       :gid     => 'pypi',
                                       :home    => '/home/pypi')

      should contain_file('/home/pypi').with(:ensure => 'directory',
                                             :owner  => 'pypi',
                                             :group  => 'pypi')
      should contain_file('/var/pypi').with(:ensure => 'directory',
                                            :owner  => 'pypi',
                                            :group  => 'pypi')
      should contain_file('/var/pypi/packages').with(:ensure => 'directory',
                                            :owner  => 'pypi',
                                            :group  => 'pypi')
      should contain_file('pypiserver_wsgi.py').with(:ensure => 'present',
                                                     :path   => '/var/pypi/pypiserver_wsgi.py',
                                                     :owner  => 'pypi',
                                                     :group  => 'pypi',
                                                     :mode   => '0755')
      should contain_file('pypiserver_wsgi.py').with_content(/pypiserver\.app\('\/var\/pypi\/packages.*\/var\/pypi\/\.htaccess/)
      should contain_file('.htaccess').with(:ensure => 'present',
                                            :path   => '/var/pypi/.htaccess',
                                            :owner  => 'pypi',
                                            :group  => 'pypi',
                                            :mode   => '0600')
      should contain_file('.htaccess-ensure-perms').with(:ensure => 'present',
                                                         :path   => '/var/pypi/.htaccess',
                                                         :owner  => 'pypi',
                                                         :group  => 'pypi',
                                                         :mode   => '0600')

      should contain_httpauth('pypiadmin').with(:ensure    => 'present',
                                                :file      => '/var/pypi/.htaccess',
                                                :password  => '1234',
                                                :mechanism => 'basic')

      should contain_apache
      should contain_apache__mod__wsgi
      should contain_apache__vhost('pypi').with(:priority      => '10',
                                               :port          => '80',
                                               :docroot       => '/var/pypi',
                                               :docroot_owner => 'pypi',
                                               :docroot_group => 'pypi',
                                               :template      => 'pypi/vhost-pypi.conf.erb')

      should contain_package('python-pip').with_ensure('present')
      should contain_package('passlib').with(:ensure   => 'present',
                                             :provider => 'pip')
      should contain_package('pypiserver').with(:ensure   => 'present',
                                                :provider => 'pip')
    end # it
  end # context

  context "On Debian system with non-default params" do

    let :facts do
      {
        :osfamily => 'Debian'
      }
    end # let

    let :params do
      {
        :pypi_http_password => 'TopSecret',
        :pypi_port          => '42',
        :pypi_root          => '/srv/somewhere'
      }
    end # let

    it do
      should contain_apache__vhost('pypi').with_port('42')
      should contain_file('pypiserver_wsgi.py').with_content(/pypiserver\.app\('\/srv\/somewhere\/packages.*\/srv\/somewhere\/\.htaccess/)
      should contain_file('.htaccess').with_path('/srv/somewhere/.htaccess')
      should contain_file('.htaccess-ensure-perms').with_path('/srv/somewhere/.htaccess')
      should contain_httpauth('pypiadmin').with(:file     => '/srv/somewhere/.htaccess',
                                                :password => 'TopSecret')
      should contain_apache__vhost('pypi').with_docroot('/srv/somewhere')
    end # it
  end # context
end # describe
