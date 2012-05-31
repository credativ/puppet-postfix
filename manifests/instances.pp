class postfix::instances (
    $manage_instances = false,
    $instances = undef,
    ) inherits postfix {

	if $manage_instances {
	    Postfix::Instance { notify => Service['postfix'] }
	    postfix::instance { $instances: }
	}
}
