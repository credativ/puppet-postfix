class postfix::instances (
    $manage_instances = false,
    $instances = undef,
    ) inherits postfix {
	Class['postfix::package'] -> Class['postfix::instances']

	if $manage_instances {
	    Postfix::Instance { notify => Service['postfix'] }
	    postfix::instance { $instances: }
	}
}
