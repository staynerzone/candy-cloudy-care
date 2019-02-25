#!/bin/bash
# Spawn random vm in random project

set -x

IMAGE_ID=$(openstack image list -f json | jq '.[] | select( .Name | contains("cirros")).ID' -r)
sleep 2
FLAVOR_ID=$(shuf -n 1 <(openstack flavor list -f json | jq '.[].ID' -r))
sleep 2
SG_ID=$(shuf -n 1 <(openstack security group list -f json | jq '.[].ID' -r))
sleep 2
AZ_ID=$(shuf -n 1 <(openstack availability zone list --compute -f json | jq '.[]["Zone Name"] | select(. | contains("internal") | not)' -r))
sleep 2
NETWORK_ID=(shuf -n 1 <(openstack network list  -f json | jq '.[] | select(.Name | contains("provider")|not).ID' -r))
sleep 2


openstack server create\
  --image $IMAGE_ID\
  --flavor $FLAVOR_ID\
  --security-group $SG_ID\
  --network $NETWORK_ID\
  --wait\
  TEST_INSTANCE
