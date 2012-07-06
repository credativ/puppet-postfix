class postfix::params {
    $ensure             = present
    $ensure_running     = true
    $ensure_enabled     = true
    $manage_instances   = false
    $config_source      = undef
    $config_template    = undef
    $instances          = undef
    $myorigin           = undef
    $smtp_bind_address  = undef
    $smtp_helo_name     = $::fqdn
    $root_alias         = undef
    $aliases            = undef
    $disabled_hosts     = undef
}
