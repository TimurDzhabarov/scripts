#!/usr/bin/env python3

import requests
import urllib3
import json
import argparse
from requests.auth import HTTPBasicAuth
# игнорирование ошибок сертификата при curl запросе
urllib3.disable_warnings()                                                  

parser = argparse.ArgumentParser()
parser.add_argument('dnsname', type=str)
#аргумент для создания итем прототипов
parser.add_argument('arg1', type=str) 
#колличество объектов в массиве json, из которых создаются итемы                                      
parser.add_argument('arg2', type=str)                                       
args = parser.parse_args()


# URL для подключения к API, который указан в шаблоне в макросах {$NIMBLENAME}
url = "{0}/tokens".format(args.dnsname)                                     
# Переменная, для передачи логина и пароля в JSON формате
login_payload = {"data":{"username":"your username","password":"your password"}}
# Подключение и запрос токена         
response = requests.post(url, verify=False, json=login_payload)             
x = response.json()

# Токен для авторизации в API
token = x['data']['session_token']
# Правило дискавера дисков
if args.arg1 == 'disks':
    url1 = "{0}/disks/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        size = int(response1.json()['data'][i]['size'])/1024/1024/1024/1024
        size1 = format(size,'.2f')
        arr1.insert(len(arr1),{"slot":i,"arrayname":response1.json()['data'][i]['array_name'],"type":response1.json()['data'][i]['type'],"serial":response1.json()['data'][i]['serial'],"model":response1.json()['data'][i]['model'],"siza":size1,"state":response1.json()['data'][i]['raid_state']})
    print((json.dumps(arr1)).replace(" ",""))

# Правило дискавера fc
elif args.arg1 == 'statusfc':
    url1 = "{0}/fibre_channel_ports/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"fcslot":i,"fcarrayname":response1.json()['data'][i]['array_name_or_serial'],"fccontr":response1.json()['data'][i]['controller_name'],"fcportname":response1.json()['data'][i]['fc_port_name'],"linkfcinfo":response1.json()['data'][i]['link_info']['link_speed'],"linkfcstatus":response1.json()['data'][i]['link_info']['link_status']})
    print((json.dumps(arr1)).replace(" ",""))

# Правило дискавера сетевых интерфейсов
elif args.arg1 == 'discovernet':
    url1 = "{0}/network_interfaces/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"netslot":i,"netarrayname":response1.json()['data'][i]['array_name_or_serial'],"netcontr":response1.json()['data'][i]['controller_name'],"netportname":response1.json()['data'][i]['name'],"linkspeed":response1.json()['data'][i]['link_speed'],"linkstatus":response1.json()['data'][i]['link_status'],"mac":response1.json()['data'][i]['mac']})
    print((json.dumps(arr1)).replace(" ",""))

    # Правило дискавера состояния полок
elif args.arg1 == 'discovershelve':
    url1 = "{0}/shelves/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"shslot":i,"arrayname":response1.json()['data'][i]['array_name'],"actrlside":response1.json()['data'][i]['ctrlrs'][0]['ctrlr_side'],"afanstatus":response1.json()['data'][i]['ctrlrs'][0]['fan_overall_status'],"atempstatus":response1.json()['data'][i]['ctrlrs'][0]['temp_overall_status'],"bctrlside":response1.json()['data'][i]['ctrlrs'][1]['ctrlr_side'],"bfanstatus":response1.json()['data'][i]['ctrlrs'][1]['fan_overall_status'],"btempstatus":response1.json()['data'][i]['ctrlrs'][1]['temp_overall_status'],"psustatus":response1.json()['data'][i]['psu_overall_status']})
    print((json.dumps(arr1)).replace(" ",""))

    # Правило дискавера СХД для получения информации о свободном и занятом месте в СХД
elif args.arg1 == 'discoverpools':
    url1 = "{0}/pools/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
       cab = int(response1.json()['data'][i]['capacity'])/1024/1024/1024/1024
       cab1 = format(cab,'.2f')
       free = int(response1.json()['data'][i]['free_space'])/1024/1024/1024/1024
       free1 = format(free,'.2f')
       arr1.insert(len(arr1),{"slot":i,"arrayname":response1.json()['data'][i]['name'],"capacity":cab1,"free":free1})
    print((json.dumps(arr1)).replace(" ",""))

   # репликация
elif args.arg1 == 'replication':
    url1 = "{0}/replication_partners/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"slot":i,"name":response1.json()['data'][i]['name'],"sync":response1.json()['data'][i]['cfg_sync_status']})
    print((json.dumps(arr1)).replace(" ",""))

