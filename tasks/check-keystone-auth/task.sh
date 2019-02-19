#!/bin/bash
#Set the colors
RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

function getToken {
  export TOKEN=`curl -i -v -k -s $OS_AUTH_URL/auth/tokens -H "Content-Type: application/json" -d ' { "auth": { "identity": { "methods": ["password"], "password": { "user": { "name": '\"$OS_USERNAME\"', "domain": { "id": "default", "name": "Default" }, "password": '\"$OS_PASSWORD\"' } } }, "scope": { "project": { "name": '\"$OS_PROJECT_NAME\"', "domain": { "id": "default", "name": "Default" } } } } }' | awk '/X-Subject-Token/ {print $2}' | tr -d '\r'`
}

getToken
#cat result

if [[ $TOKEN == "" ]]; then
  echo -e "${RED}ERROR. CANNOT OBTAIN A TOKEN FROM KEYSTONE${NC}"
  exit 1
else
  echo -e "${GREEN}SUCCESSFULLY FETCHED TOKEN FROM KEYSTONE${NC}"i
#Put the token fo file "token/token"
cat << VWFS > token/token
export TOKEN=`echo \$TOKEN`
VWFS
  exit 0
fi
