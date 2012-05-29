class postfix {
  exec { 'update-aliases':
    command     => '/usr/bin/newaliases',
    path        => '/etc/init.d:/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => true,
  }

  file { '/etc/aliases':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['update-aliases'],
  }

  package { 'postfix':
    ensure => present,
  }

  service { 'postfix':
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
  }
}
