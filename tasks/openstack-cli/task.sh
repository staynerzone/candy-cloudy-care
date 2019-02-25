#!/bin/bash
#Set the colors

set -x

RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

SLOW_APIS=0

KEYSTONE_T=5.0
KEYSTONE_TIME=$(/usr/bin/time -f'%e' openstack token issue 2>&1 1>/dev/null)
if [[ $KEYSTONE_TIME > 0 && $KEYSTONE_TIME > $KEYSTONE_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "KEYSTONE (token): i.o ($KEYSTONE_TIME sec)" ; fi

KEYSTONE_T=5.0
KEYSTONE_TIME=$(/usr/bin/time -f'%e' openstack user list 2>&1 1>/dev/null)
if [[ $KEYSTONE_TIME > 0 && $KEYSTONE_TIME > $KEYSTONE_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "KEYSTONE (user): i.o ($KEYSTONE_TIME sec)" ; fi

NOVA_T=8.0
NOVA_TIME=$(/usr/bin/time -f'%e' openstack server list --all-projects 2>&1 1>/dev/null)
if [[ $NOVA_TIME > 0 && $NOVA_TIME > $NOVA_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "NOVA: i.o ($NOVA_TIME sec)" ; fi

NEUTRON_T=5.0
NEUTRON_TIME=$(/usr/bin/time -f'%e' openstack network list 2>&1 1>/dev/null)
if [[ $NEUTRON_TIME > 0 && $NEUTRON_TIME > $NEUTRON_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "NEUTRON: i.o ($NEUTRON_TIME sec)" ; fi

CINDER_T=7.0
CINDER_TIME=$(/usr/bin/time -f'%e' openstack volume list --all-projects 2>&1 1>/dev/null)
if [[ $CINDER_TIME > 0 && $CINDER_TIME > $CINDER_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "CINDER: i.o ($CINDER_TIME sec)" ; fi

GLANCE_T=7.0
GLANCE_TIME=$(/usr/bin/time -f'%e' openstack image list 2>&1 1>/dev/null)
if [[ $GLANCE_TIME > 0 && $GLANCE_TIME > $GLANCE_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "GLANCE: i.o ($GLANCE_TIME sec)" ; fi

DESIGNATE_T=5.0
DESIGNATE_TIME=$(/usr/bin/time -f'%e' openstack zone list --all-projects 2>&1 1>/dev/null)
if [[ $DESIGNATE_TIME > 0 && $DESIGNATE_TIME > $DESIGNATE_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "DESIGNATE: i.o ($DESIGNATE_TIME sec)" ; fi


if [[ $SLOW_APIS -gt 0 ]]; then
  echo "APIs responding slow!";
  exit 1;
else
  echo "APIs operating in time!";
  exit 0;
fi
