#!/usr/bin/env bash

set -e
set -x

function start_tempest_tests {
    echo -e "\n === CONFIGURING TEMPEST === \n"
    # ensure rally db is present
    rally db ensure

    # configure deployment for current region with existing users
    rally deployment create --file /etc/keystone/tempest_deployment_config.json --name tempest_deployment

    # check if we can reach openstack endpoints
    rally --debug deployment check

    # create tempest verifier fetched from our repo
    rally --debug verify create-verifier --type tempest --name keystone-tempest-verifier --system-wide --source https://github.com/sapcc/tempest --version ccloud

    # configure tempest verifier taking into account the auth section values provided in tempest_extra_options file
    rally --debug verify configure-verifier --extend /etc/keystone/tempest_extra_options

    # run the actual tempest api tests for keystone
    rally verify start --concurrency 1 --detailed --pattern tempest.api.identity.v3.
    rally verify start --concurrency 1 --detailed --pattern tempest.api.identity.admin.v3.
    #rally verify start --concurrency 1 --detailed --pattern keystone_tempest_plugin.
}

start_tempest_tests
