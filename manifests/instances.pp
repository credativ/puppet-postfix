class postfix::instances (
    $manage_instances = false,
    $instances = undef,
    ) inherits postfix {

    include postfix::setperms

    Class['postfix'] -> Class['postfix::instances']

    if $manage_instances {
        if ! is_hash($instances) {
            fail("postfix: instances need to be specified as a hash of instances")
        }

        Postfix::Instance { 
            notify  => [
                Exec["postfix/set_perms"],
                Service['postfix'],
            ],
            require => [
                Class['postfix'],
                Exec['init_multi_instance_support'],
            ]

        }
        
        exec { 'init_multi_instance_support':
            command => '/usr/sbin/postmulti -e init',
            unless  => 'grep "multi_instance_enable = yes" /etc/postfx/main.cf'
        }

        create_resources(postfix::instance, $instances)
    }
}
