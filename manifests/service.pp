class postfix::service (
    $ensure     = 'running',
    $enabled    = true
    ) inherits postfix::params {

    Class['postfix::package'] -> Class['postfix::service']

    service { 'postfix':
        ensure      => $ensure,
        enabled     => $enabled,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['postfix'],
    }
}
