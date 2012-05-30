class postfix::instances ($instances) inherits postfix{
    Postfix::Instance { notify => Service['postfix'] }
    postfix::instance { $instances: }
}
