#!/bin/bash
# Spawn random vm in random project

IMAGE_ID=$(openstack image list -f json | jq '.[] | select( .Name | contains("cirros")).ID' -r)
FLAVOR_ID=$(shuf -n 1 <(openstack flavor list -f json | jq '.[].ID' -r))
#SG_ID=$(shuf -n 1 <(openstack security group list -f json | jq '.[].ID' -r))
AZ_ID=$(shuf -n 1 <(openstack availability zone list --compute -f json | jq '.[]["Zone Name"] | select(. | contains("internal") | not)' -r))
NETWORK_ID=$(shuf -n 1 <(openstack network list  -f json | jq '.[] | select(.Name | contains("provider")|not).ID' -r))


echo "Creating  ..."
TIME=$(/usr/bin/time -f'%es' \
openstack server create\
  --image $IMAGE_ID\
  --flavor $FLAVOR_ID\
  --network $NETWORK_ID\
  --wait\
  TEST_INSTANCE)
echo "...created!"

echo "Deleting ..."
ID=$(openstack server list --all-projects -f json | jq '.[] | select( .Name | contains("TEST_INSTANCE")).ID' -r)
openstack server delete $ID
echo "...deleted! ($ID)"
