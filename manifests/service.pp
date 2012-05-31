class postfix::service (
    ensure => 'running',
    enabled => true
    ) inherits postfix::params {

    service { 'postfix':
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['postfix'],
    }
}
