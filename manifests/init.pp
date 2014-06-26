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
#   Weither to ensure running postfix or not.
#   Default: running
#
# [*ensure_enabled*]
#   Weither to ensure that postfix is started on boot or not.
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
#   Weither to manage configuration of postfix at all. If this is set to false
#   no configuration files (main.cf, aliases, etc.) will be managed at all.
#
# [*manage_aliases*]
#   Weither to manage the aliases file. Note that this also creates an
#   alias for the root user, so root_alias should be set to a sensible value.
#
# [*manage_instances*]
#   Weither instances should be managed. Only useful in conjunction
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
    $ensure             = params_lookup('ensure'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
    $manage_config      = params_lookup('manage_config'),
    $manage_instances   = params_lookup('manage_instances'),
    $manage_aliases     = params_lookup('manage_aliases'),
    $config_source      = params_lookup('config_source'),
    $config_template    = params_lookup('config_template'),
    $instances          = params_lookup('instances'),
    $myorigin           = params_lookup('myorigin'),
    $smtp_bind_address  = params_lookup('smtp_bind_address'),
    $smtp_helo_name     = params_lookup('smtp_helo_name'),
    $root_alias         = params_lookup('root_alias'),
    $aliases            = params_lookup('aliases'),
    $disabled_hosts     = params_lookup('disabled_hosts'),
    $localdomain        = params_lookup('localdomain'),
    $relayhost          = params_lookup('relayhost'),
    $inet_interfaces    = params_lookup('inet_interfaces'),

    ) inherits postfix::params {

    Class['postfix::package'] -> Class['postfix::instances']
        -> Class['postfix::service']

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
        enabled => $real_enabled
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
