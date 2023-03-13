#!/bin/bash
##  .SYNOPSIS
##  Grafana Dashboard for HPE StoreOnce G4 - Using RestAPI to InfluxDB Script
##
##  .DESCRIPTION
##  This Script will query the HPE StoreOnce RESTful API and send the data directly to InfluxDB, which can be used to present it to Grafana.
##  The Script and the Grafana Dashboard it is provided as it is, and bear in mind you can not open support Tickets regarding this project. It is a Community Project
##
##  .Notes
##  NAME:  hpe_storeonce_grafana.sh
##  ORIGINAL NAME: hpe_storeonce_grafana.sh
##  LASTEDIT: 05/09/2020
##  VERSION: 1.0
##  KEYWORDS: storeonce, InfluxDB, Grafana

##  .Link
##  https://jorgedelacruz.es/
##  https://jorgedelacruz.uk/

##
# Configurations
##

PARAM1="${1}"
PARAM2="${2}"

# Endpoint URL for login action
storeonceUsername="YOUR USERNAME" #Your username, if using domain based account, please add it like user@domain.com (if you use domain\account it is not going to work!)
storeoncePassword='YOUR PASSWORD'
storeonceRestServer="https://"YOUR URL""
storeonceRestPort="443" #Default Port
storeonceSessionBearer=$(curl -X POST "$storeonceRestServer:$storeonceRestPort/pml/login/authenticatewithobject" -H "Content-Type:application/json" -H "Accept:application/json" -d '{"username":"'$storeonceUsername'","password":"'$storeoncePassword'","grant_type":"password"}' -k --silent | jq --raw-output ".access_token")



#HPE StoreOnce Appliance Information
HPEUrl="$storeonceRestServer:$storeonceRestPort/api/v1/management-services/federation/members"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)

    if [ $PARAM1 = HPEHostname ]; then
#		HPEHostname=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[0].hostname" | awk '{gsub(/ /,"\\ ");print}')
                HPEHostname=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[0] + {"slot":0}")
		echo [$HPEHostname]
    fi

#HPE StoreOnce Dashboard Information
HPEUrl="$storeonceRestServer:$storeonceRestPort/api/v1/data-services/dashboard/overview"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)

    if [ $PARAM1 = HPEVersion ]; then
#		HPEVersion=$(echo "$HPEDashboardUrl" | jq --raw-output ".highestSoftwareVersion")
               HPEVersion=$(echo "$HPEDashboardUrl" | jq --raw-output ".")
		echo [$HPEVersion]
    fi

#HPE StoreOnce Appliance Metrics
#CPU
TimeEnd=$(date -u --date="-1 minutes" +%FT%TZ)
TimeStart=$(date -u --date="-61 minutes" +%FT%TZ)
HPEUrl="$storeonceRestServer:$storeonceRestPort/api/v1/management-services/hardware/parametrics-cpu?startDate=$TimeStart&endDate=$TimeEnd&samples=5"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)
declare -i arraycpu=0

    if [ $PARAM1 = HPEpercentageCpuUsage ]; then

for id in $(echo "$HPEDashboardUrl" | jq -r '.members[].timestamp'); do
#    HPEpercentageCpuUsage=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraycpu].percentageCpuUsage")
    HPEpercentageCpuUsage=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraycpu] + {"slot":0}")
done
	echo [$HPEpercentageCpuUsage]
	fi

#RAM
HPEUrl="$storeonceRestServer:$storeonceRestPort/api/v1/management-services/hardware/parametrics-memory?startDate=$TimeStart&endDate=$TimeEnd&samples=5"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)

declare -i arrayram=0

	if [ $PARAM1 = HPEpercentageMemoryUsage ]; then

for id in $(echo "$HPEDashboardUrl" | jq -r '.members[].timestamp'); do
     HPEpercentageMemoryUsage=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arrayram]")
done
	echo [$HPEpercentageMemoryUsage]
	fi

#DISK
HPEUrl="$storeonceRestServer:$storeonceRestPort/api/v1/management-services/hardware/parametrics-disk?startDate=$TimeStart&endDate=$TimeEnd&samples=5"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)

declare -i arraydisk=0

	if [ $PARAM1 = HPEOSpercentageDiskUsage ]; then

for id in $(echo "$HPEDashboardUrl" | jq -r '.members[].timestamp'); do
#    HPETimestamp=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].timestamp")
    HPEOSpercentageDiskUsage=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0]")
 #   HPEOSreadThroughput=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].readThroughput")
  #  HPEOSwriteThroughput=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].writeThroughput")
   # HPEOSreadsPerSecond=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].readsPerSecond")
  #  HPEOSwritesPerSecond=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].writesPerSecond")
  #  HPEDATApercentageDiskUsage=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].percentageDiskUsage")
  #  HPEDATAreadThroughput=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].readThroughput")
  #  HPEDATAwriteThroughput=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].writeThroughput")
  #  HPEDATAreadsPerSecond=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].readsPerSecond")
  #  HPEDATAwritesPerSecond=$(echo "$HPEDashboardUrl" | jq --raw-output ".members[$arraydisk].disks[0].writesPerSecond")
  #  HPETimeUnix=$(date -d "$HPETimestamp" +"%s")

    arraydisk=$arraydisk+1   
done
	echo $HPEOSpercentageDiskUsage
	fi

#ALERTS
HPEUrl="$storeonceRestServer:$storeonceRestPort/rest/alerts"
HPEDashboardUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:Bearer $storeonceSessionBearer" "$HPEUrl" 2>&1 -k --silent)


        if [ $PARAM1 =  HPEalerts ]; then

     HPEalerts=$(echo "$HPEDashboardUrl" | jq --raw-output ".")
        echo $HPEalerts
        fi


