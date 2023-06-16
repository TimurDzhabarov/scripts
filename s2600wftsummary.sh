#!/bin/bash
PARAM1="${1}"
PARAM2="${2}"
PARAM3="${3}"

URL="https://$PARAM1/redfish/v1/Chassis/RackMount/"
URL1="https://$PARAM1"
URL2=$(curl -k -s -u $PARAM2:$PARAM3 $URL -X GET | jq -r '.Links''.ComputerSystems[]."@odata.id"')
SUMMARY=$(curl -k -s -u $PARAM2:$PARAM3 $URL1$URL2 -X GET | jq)
echo "$SUMMARY" | jq
