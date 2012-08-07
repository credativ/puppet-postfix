class postfix (
    $ensure             = params_lookup('ensure'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
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
