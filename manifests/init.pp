class postfix (
    $ensure             = params_lookup("ensure"),
    $ensure_running     = params_lookup("ensure_running"),
    $ensure_enabled     = params_lookup("ensure_enabled"),
    $manage_instances   = params_lookup("manage_instances"),
    $config_source      = params_lookup("config_source"),
    $config_template    = params_lookup("config_template"),
    $instances          = params_lookup("instances"),

    ) inherits postfix::params {

    Class['postfix::package'] -> Class['postfix::instances']
        -> Class['postfix::service']

    class { 'postfix::instances':
        manage_instances => $manage_instances,
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
            content => template("postfix/${config_template}")
        }
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
