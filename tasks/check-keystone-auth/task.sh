#!/bin/bash
#Set the colors
RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

function getToken {
  export TOKEN=`curl -i -k -s https://$OS_AUTH_URL:5000/v3/auth/tokens -H "Content-Type: application/json" -d ' { "auth": { "identity": { "methods": ["password"], "password": { "user": { "name": '\"$OS_USERNAME\"', "domain": { "id": "bc273d7d1a7c47d0b6d1d42570c76099", "name": '\"${OS_AUTH_URL:8}\"' }, "password": '\"$OS_PASSWORD\"' } } }, "scope": { "project": { "name": '\"$OS_PROJECT_NAME\"', "domain": { "id": "bc273d7d1a7c47d0b6d1d42570c76099", "name": '\"${OS_AUTH_URL:8}\"' } } } } }' | awk '/X-Subject-Token/ {print $2}' | tr -d '\r'`
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
