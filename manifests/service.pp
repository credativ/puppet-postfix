class postfix::service (
    ensure => 'running',
    enabled => true
    ) inherits postfix::params {

    Class['postfix::package'] -> Class['postfix::service']

    service { 'postfix':
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['postfix'],
    }
}
