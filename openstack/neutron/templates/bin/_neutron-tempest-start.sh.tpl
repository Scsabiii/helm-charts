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
  rally --debug verify start --concurrency 1 --detailed --pattern neutron_tempest_plugin.api --skip-list /neutron-etc/tempest_skip_list.yaml
}

cleanup_tempest_leftovers() {

  # Subnet CIDR pattern from tempest.conf: https://docs.openstack.org/tempest/latest/sampleconf.html

  # Due to a clean up bug we need to clean up ourself the ports, networks and routers: https://bugs.launchpad.net/neutron/+bug/1759321

  # grep all ports from Tempestuser 1 and put in a list, only IPv4
  export OS_USERNAME='tempestuser1'
  export OS_TENANT_NAME='tempest1'
  export OS_PROJECT_NAME='tempest1'
  openstack port list | grep "ip_address='10.100.0." | grep -E "ACTIVE|DOWN" | awk '{ print $2 }' >> /tmp/myList.txt

  # grep all ports from Tempestuser 2 and put in a list, only IPv4
  export OS_USERNAME='tempestuser2'
  export OS_TENANT_NAME='tempest2'
  export OS_PROJECT_NAME='tempest2'  
  openstack port list | grep "ip_address='10.100.0." | grep -E "ACTIVE|DOWN" | awk '{ print $2 }' >> /tmp/myList.txt

  # grep all ports from admin and put in a list, only IPv4
  export OS_USERNAME='admin'
  export OS_TENANT_NAME='admin'
  export OS_PROJECT_NAME='admin'
  openstack port list | grep "ip_address='10.100.0." | grep -E "ACTIVE|DOWN" | awk '{ print $2 }' >> /tmp/myList.txt
  # sort unique the list
  sort -u /tmp/myList.txt > /tmp/mySortedList.txt
  # disable and remove ip from the ports and delete the port
  while read port; do openstack port set ${port} --disable --no-fixed-ip && openstack port delete ${port}; done < /tmp/mySortedList.txt

  # Delete all networks and routers for Tempestuser 1
  export OS_USERNAME='tempestuser1'
  export OS_TENANT_NAME='tempest1'
  export OS_PROJECT_NAME='tempest1'
  for network in $(openstack network list | grep -E "tempest|test|newnet|smoke-network" | awk '{ print $2 }'); do openstack network delete ${network}; done 
  for router in $(openstack router list | grep -E "tempest|test" | awk '{ print $2 }'); do openstack router delete ${router}; done

  # Delete all networks and routers for Tempestuser 2
  export OS_USERNAME='tempestuser2'
  export OS_TENANT_NAME='tempest2'
  export OS_PROJECT_NAME='tempest2'
  for network in $(openstack network list | grep -E "tempest|test|newnet|smoke-network" | awk '{ print $2 }'); do openstack network delete ${network}; done 
  for router in $(openstack router list | grep -E "tempest|test" | awk '{ print $2 }'); do openstack router delete ${router}; done

  # Delete all networks and routers for Admin
  export OS_USERNAME='admin'
  export OS_TENANT_NAME='admin'
  export OS_PROJECT_NAME='admin'
  for network in $(openstack network list | grep -E "tempest" | awk '{ print $2 }'); do openstack network delete ${network}; done 
}

main() {
  start_tempest_tests
  TEMPEST_EXIT_CODE=$?
  cleanup_tempest_leftovers
  CLEANUP_EXIT_CODE=$?
  exit $(($TEMPEST_EXIT_CODE + $CLEANUP_EXIT_CODE))
}

main
