class postfix::setperms {

    exec { "postfix_setperms":
        command     => "/usr/sbin/postfix set-permissions",
        onlyif      => "/usr/sbin/postfix check 2>&1|/bin/grep 'Permission denied'",
        returns     => [0, 1]
    }
}


