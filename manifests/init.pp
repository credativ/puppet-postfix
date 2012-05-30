class postfix (
    $ensure             = params_lookup("ensure"),
    $ensure_running     = params_lookup("ensure_running"),
    $ensure_enabled     = params_lookup("ensure_enabled"),
    $manage_instances   = params_lookup("manage_instances"),
    $config_source      = params_lookup("config_source"),
    $config_template    = params_lookup("config_template"),
    $instances          = params_lookup("instances"),
   
    ) inherits postfix::params {
   
    if $manage_instance {
        class { 'postfix::instances':
            instances   => $instances,
            stage       => 'setup'
        }
    }
    package { 'postfix':
        ensure => $ensure
    }

    file { '/etc/aliases':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['update-aliases'],
    }

    package { 'postfix':
        ensure => present,
    }

    service { 'postfix':
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
    }
}
