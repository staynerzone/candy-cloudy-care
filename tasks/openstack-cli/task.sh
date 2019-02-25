#!/bin/bash
#Set the colors
RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

openstack catalog list
