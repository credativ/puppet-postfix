define postfix::instance (
  $instance=$title,
  $ensure = 'enabled'
) {
    $instance_name  = "postfix-$instance"
    $queue_dir      = "/var/spool/${instance_name}" 
    $data_dir       = "/var/lib/${instance_name}" 
    $config_dir    = "/etc/${instance_name}"

    file { "${queue_dir}":
        ensure => directory,
        owner   => 'root',
        group   => 'root'
    }

    file { "${data_dir}":
        ensure  => directory,
        owner   => 'postfix',
        group   => 'postfix'
    }

    file { "${config_dir}": 
        ensure  => directory,
        owner   => 'root',
        group   => 'root'
    }

    file { "$config_dir/dynamicmaps.cf": 
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        require => File[$config_dir]
    }

    exec { "init-instance-${instance_name}":
        command => "/usr/sbin/postmulti -I ${instance_name} -e create",
        unless  => "/usr/sbin/postmulti -l | /bin/grep '^${instance_name} '",
    }

    if $ensure == 'enabled' {
        exec { "enable-instance-${instance_name}":
            command => "postmulti -i $instance_name -e enable",
            unless  => "grep -q 'multi_instance_enable = yes' ${c_dir}/main.cf",
            require => Exec["init-instance-${instance}"]
        }
    }
}
