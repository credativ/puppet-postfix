class postfix::setperms {

    exec { "postfix_setperms":
        command     => "/usr/sbin/postfix set-permissions",
        onlyif      => "/usr/sbin/postfix check 2>&1|/bin/grep 'Permission denied'",
        subscribe   => Exec['init-instance-${instance_name}'],
        require     => File["${config_dir}/dynamicmaps.cf"],
        returns     => [0, 1]
    }
}


