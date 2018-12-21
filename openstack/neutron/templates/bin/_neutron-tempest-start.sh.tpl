#!/usr/bin/env bash

set -xo pipefail

function start_tempest_tests {
  
  echo -e "\n === CONFIGURING TEMPEST === \n"

  # ensure rally db is present
  rally db ensure

  # configure deployment for current region with existing users
  rally deployment create --file /neutron-etc/tempest_deployment_config.json --name tempest_deployment

  # check if we can reach openstack endpoints
  rally deployment check

  # create tempest verifier fetched from our repo
  rally --debug verify create-verifier --type tempest --name neutron-tempest-verifier --system-wide --source https://github.com/sapcc/tempest --version ccloud

  # configure tempest verifier taking into account the auth section values provided in tempest_extra_options file
  rally --debug verify configure-verifier --extend /neutron-etc/tempest_extra_options

  # run the actual tempest tests for neutron
  echo -e "\n === STARTING TEMPEST TESTS FOR neutron === \n"
  rally --debug verify start --concurrency 1 --detailed --pattern neutron_tempest_plugin.api --xfail-list /neutron-etc/tempest_expected_failures.yaml
}

start_tempest_tests
