#!/bin/bash
#Set the colors

RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

SLOW_APIS=0

KEYSTONE_T=5.0
KEYSTONE_TIME=$(/usr/bin/time -f'%e' openstack token issue 2>&1 1>/dev/null)
if [[ $KEYSTONE_TIME > 0 && $KEYSTONE_TIME > $KEYSTONE_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "keystone: i.o ($KEYSTONE_TIME sec)" ; fi

NOVA_T=8.0
NOVA_TIME=$(/usr/bin/time -f'%e' openstack server list --all-projects 2>&1 1>/dev/null)
if [[ $NOVA_TIME > 0 && $NOVA_TIME > $NOVA_T ]]; then SLOW_APIS=`expr $SLOW_APIS + 1` ; else echo "NOVA: i.o ($NOVA_TIME sec)" ; fi
