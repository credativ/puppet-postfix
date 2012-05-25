class postfix::instances::hiera {
    $postfix_instances = hiera('postfix_instances')

    postfix::instance { $postfix_instances: }
}
