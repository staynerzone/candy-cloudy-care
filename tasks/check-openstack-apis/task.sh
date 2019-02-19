#!/bin/bash

#Set the colors
RED='\033[0;31m' # for state
GREEN='\033[0;32m' # for state
CYAN='\033[0;36m' # for internal exclusions
PURPLE='\033[0;35m' # for service names
ORANGE='\033[0;33m' # for url names
NC='\033[0m'

#Get the required info and save it to the file response
curl -s -i -k $OS_AUTH_URL/auth/tokens -H "Content-Type: application/json" -d ' { "auth": { "identity": { "methods": ["password"], "password": { "user": { "name": '\"$OS_USERNAME\"', "domain": { "id": "default", "name": "Default" }, "password": '\"$OS_PASSWORD\"' } } }, "scope": { "project": { "name": '\"$OS_PROJECT_NAME\"', "domain": { "id": "default", "name": "Default" } } } } }' 2>&1 -o response

#Remove the first 10 lines from response and extract data from the rest of the file
sed -e '1,10d' response | jq '.[].catalog[] | [{name: .name, interface: .endpoints[].interface, url: .endpoints[].url}]' 2>&1 > api-endpoints

#Get token from keyval
cat keyval/keyval.properties | sed 's/=/ /' | grep TOKEN > token
source token

STATUS_CODE=0

for i in `cat api-endpoints | jq '.[] | {name: .name,url: .url,interface: .interface}' -rc`
do

  SERVICE=$(echo $i | awk -F "," '{print $1}' | awk -F ":" '{print $2}')
  URL=$(echo $i | awk -F "," '{print $2}' | awk -F '":"' '{print $2}' | tr -d '"')
  IFACE=$(echo $i | awk -F "," '{print $3}' | awk -F ":" '{print $2}')

  if [[ $FILTER != "" ]]; then ### if a filter is set we do only want information about this endpoint
    if [[ $SERVICE = *"$FILTER"* ]]; then
      echo "{ \"$FILTER-endpoint\": \"$URL\" }" > endpoints/$FILTER-endpoint.yml
      exit 0
    else
      continue
    fi
  fi

  EXTENSION=""

  if [[ $URL = *"10.37"* ]]; then
    ## Just skip http public ifaces. they won't get used by any of our services.
    continue;
  fi

  if [[ $SERVICE = *"cinder"* ]]; then
    EXTENSION="/extensions"
  fi

  if [[ $SERVICE = *"heat"* ]]; then
    EXTENSION="/stacks"
  fi

  if [[ $SERVICE = *"heat-cfn"* ]]; then
#get the first 49 chars from the URL
    URL=${URL:0:49}
    EXTENSION=
  fi

  if [[ $SERVICE = *"TrilioVaultWLM"* || $SERVICE = *"compute_legacy"* ]]; then
    ## We are not interested in those services.
    continue;
  fi

  if [[ $(curl -k -L -H "X-Auth-Token: $TOKEN" --connect-timeout 3 --write-out '%{response_code}' --silent --output /dev/null $URL$EXTENSION) = "200" || $(curl -k -L -H "X-Auth-Token: $TOKEN" --connect-timeout 3 --write-out '%{response_code}' --silent --output /dev/null $URL$EXTENSION) = "300" ]]
  then
    STATUS="${GREEN}success${NC}"
  else
    STATUS="${RED}failed${NC}"
    STATUS_CODE=$(expr $STATUS_CODE + 1)
  fi

  echo -e "Now testing ($IFACE) Service: ${PURPLE}$SERVICE${NC} with URL: ${ORANGE}$URL$EXTENSION${NC} .............. $STATUS"

done

if [[ $STATUS_CODE -ne 0 ]]; then
  echo -e "${RED}ERROR. NOT ALL APIs ARE AVAILABLE${NC}"
  exit 1
else
  echo -e "${GREEN}SUCCESS. ALL APIs ARE AVAILABLE${NC}"
  exit 0
fi

#cat << VWFS > alert/alert-message.json
#{
#  "reporting-job": "check-iaas-api",
#  "alert-name": "Some OpenStack API endpoints are not reachable",
#  "severity": "warning",
#  "info-text": "OpenStack API failure",
#  "summary": "Check pipeline to see which endpoint checking failed..."
#}
#VWFS

#  exit 1
