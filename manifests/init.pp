class postfix (
    $ensure             = params_lookup("ensure"),
    $ensure_running     = params_lookup("ensure_running"),
    $ensure_enabled     = params_lookup("ensure_enabled"),
    $manage_instances   = params_lookup("manage_instances"),
    $config_source      = params_lookup("config_source"),
    $config_template    = params_lookup("config_template"),
    $instances          = params_lookup("instances"),

    ) inherits postfix::params {

    if $manage_instances {
        class { 'postfix::instances':
            instances   => $instances,
            stage       => 'setup'
        }
    }

    class { 'postfix::package':
	ensure => $ensure,
    }

    class { 'postfix::service':
	ensure	=> $ensure_running,
	enabled	=> $ensure_enabled
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
