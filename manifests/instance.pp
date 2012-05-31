define postfix::instance (
  $instance=$title,
  $config_dir=undef,
  $queue_dir=undef,
  $data_dir=undef
) {
    $instance_name = "postfix-$instance"

    if $config_dir {
        $c_dir = $config_dir
    } else {
        $c_dir = "/etc/$instance_name"
    }

    if $queue_dir {
        $q_dir = $queue_dir
    } else {
        $q_dir = "/var/spool/$instance_name"
    }

    if $data_dir {
        $d_dir = $data_dir
    } else {
        $d_dir = "/var/lib/$instance_name"
    }

    file { $q_dir:
        ensure => directory,
        notify => Exec["check-instance-${instance_name}"]
    }

    file { $d_dir:
        ensure => directory,
        notify => Exec["check-instance-${instance_name}"]
    }

    Exec {
        path => ['/usr/sbin', '/usr/bin', '/bin']
    }

    exec { "check-instance-${instance_name}":
        command     => '/usr/sbin/postfix check',
        returns     => [0, 1],
        refreshonly => true
    }

    exec { "init-instance-support":
        command => "postmulti -e init",
        unless => "grep -q multi_instance_wrapper /etc/postfix/main.cf"
    }

    exec { "init-instance-$instance":
        command => "postmulti -I $instance_name -e create \
            config_directory=$c_dir queue_directory=$q_dir \
            data_directory=$d_dir",
        unless  => "postconf multi_instance_directories|grep -q $instance_name",
    }

    exec { "enable-instance-$instance":
	command => "postmulti -i $instance_name -e enable",
	unless  => "grep -q 'multi_instance_enable = yes' ${c_dir}/main.cf",
	require => Exec["init-instance-${instance}"]
    }
}
