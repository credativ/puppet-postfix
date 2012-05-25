class postfix {
    package { 'postfix':
        ensure => present
    }

    file { '/etc/aliases':
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Exec['update-aliases']
    }

    exec { 'update-aliases':
        command     => '/usr/bin/newaliases',
        refreshonly => true,

    }

    service { 'postfix':
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true
    }
}
