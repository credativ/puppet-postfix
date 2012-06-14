class postfix::package (
    $ensure = 'present',
    ) inherits postfix::params {

    package { 'postfix':
        ensure => $ensure,
    }
}
