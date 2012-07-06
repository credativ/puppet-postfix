class postfix (
    $ensure             = params_lookup("ensure"),
    $ensure_running     = params_lookup("ensure_running"),
    $ensure_enabled     = params_lookup("ensure_enabled"),
    $manage_instances   = params_lookup("manage_instances"),
    $config_source      = params_lookup("config_source"),
    $config_template    = params_lookup("config_template"),
    $instances          = params_lookup("instances"),
    $myorigin           = params_lookup("myorigin"),
    $smtp_bind_address  = params_lookup("smtp_bind_address"),
    $smtp_helo_name     = params_lookup("smtp_helo_name"),
    $root_alias         = params_lookup("root_alias"),
    $aliases            = params_lookup("aliases"),

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

    class { 'postfix::service':
        ensure  => $ensure_running,
        enabled => $ensure_enabled
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

    file { '/etc/aliases':
        ensure      => present,
        content     => template('aliases.erb')
        mode        => '0644'
        owner       => 'root',
        group       => 'root'
    }

    exec { 'update-aliases':
        command     => '/usr/sbin/update-aliases',
        refreshonly => true
    }

    file { '/etc/aliases':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['update-aliases'],
        require => Package['postfix'],
    }

}
