# = Class: postfix
#
# Module to manage postfix
#
# == Requirements:
#
# - This module makes use of the example42 functions in the puppi module
#   (https://github.com/credativ/puppet-example42lib)
#
# == Parameters:
#
# [*ensure*]
#   What state to ensure for the package. Accepts the same values
#   as the parameter of the same name for a package type.
#   Default: present
#   
# [*ensure_running*]
#   Whether to ensure running postfix or not. The special value 'ignore'
#   tells puppet not to manage the service status
#   Default: running
#
# [*ensure_enabled*]
#   Whether to ensure that postfix is started on boot or not.
#   Default: true
#
# [*config_source*]
#   Specify a configuration source for the configuration (main.cf). If this
#   is specified it is used instead of a template-generated configuration
#
# [*config_template*]
#   Define a template for the configuration.
#
# [*disabled_hosts*]
#   A list of hosts whose postfix will be disabled, if their
#   hostname matches a name in the list.
#
# [*manage_config*]
#   Whether to manage configuration of postfix at all. If this is set to false
#   no configuration files (main.cf, aliases, etc.) will be managed at all.
#
# [*manage_aliases*]
#   Whether to manage the aliases file. Note that this also creates an
#   alias for the root user, so root_alias should be set to a sensible value.
#
# [*manage_instances*]
#   Whether instances should be managed. Only useful in conjunction
#   with the instances parameter.
#   (Default: False)
#
# [*instances*]
#   A list of postfix instances that should be created (only useful in
#   conjunction with manage_instances)
#
# [*root_alias*]
#   Defines the alias for root mail.
#
# [*aliases*]
#   Allows further aliases to be defined.

# [*myorigin*]
#   Refers to the myorigin configuration paramater.
#
# [*localdomain*]
#   Should describe the localdomain of this host. Will be added to the
#   mydestination configuration
#
# [*relayhost*]
#   Allows to define a relayhost in the configuration.
#
# [*inet_interfaces*]
#   Allows to define a value for the inet_interfaces parameter.
#
# == Author:
#
#   Patrick Schoenfeld <patrick.schoenfeld@credativ.de
class postfix (
    $ensure             = $postfix::params::ensure,
    $ensure_running     = $postfix::params::ensure_running,
    $ensure_enabled     = $postfix::params::ensure_enabled,
    $manage_config      = $postfix::params::manage_config,
    $manage_instances   = $postfix::params::manage_instances,
    $manage_aliases     = $postfix::params::manage_aliases,
    $config_source      = $postfix::params::config_source,
    $config_template    = $postfix::params::config_template,
    $instances          = $postfix::params::instances,
    $myorigin           = $postfix::params::myorigin,
    $smtp_bind_address  = $postfix::params::smtp_bind_address,
    $smtp_helo_name     = $postfix::params::smtp_helo_name,
    $root_alias         = $postfix::params::root_alias,
    $aliases            = $postfix::params::aliases,
    $disabled_hosts     = $postfix::params::disabled_hosts,
    $localdomain        = $postfix::params::localdomain,
    $relayhost          = $postfix::params::relayhost,
    $inet_interfaces    = $postfix::params::inet_interfaces,

    ) inherits postfix::params {

    Class['postfix::package'] -> Class['postfix::instances']

    $bool_manage_instances = any2bool($manage_instances)
    class { 'postfix::instances':
        manage_instances => $bool_manage_instances,
        instances => $instances,
    }

    class { 'postfix::package':
        ensure => $ensure,
    }

    if $::hostname in $disabled_hosts {
        $real_running = 'stopped'
        $real_enabled = false
    } else {
        $real_running = $ensure_running
        $real_enabled = $ensure_enabled
    }

    class { 'postfix::service':
        ensure  => $real_running,
        enabled => $real_enabled,
        require => Class['postfix::instances'],
    }

    if $manage_config {
        if $config_template {
            file { '/etc/postfix/main.cf':
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template("postfix/${config_template}"),
                notify  => Service['postfix']
            }
        }

        exec { 'update-aliases':
            command     => '/usr/bin/newaliases',
            refreshonly => true
        }
        if $manage_aliases {
            file { '/etc/aliases':
                ensure  => present,
                content => template('postfix/aliases.erb'),
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                notify  => Exec['update-aliases'],
                require => Package['postfix'],
            }
        }
    }


}
