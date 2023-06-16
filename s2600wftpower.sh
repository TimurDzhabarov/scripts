#!/bin/bash
PARAM1="${1}"
PARAM2="${2}"
PARAM3="${3}"

URL="https://$PARAM1/redfish/v1/Chassis/RackMount/Baseboard/Power"
SUMMARY=$(curl -k -s -u $PARAM2:$PARAM3 $URL -X GET | sed -e 's|MemberId|{#ID}|g' -e 's|Name|{#NAME}|g'| jq)
echo "$SUMMARY" | jq
