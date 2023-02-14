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
login_payload = {"data":{"username":"username","password":"password"}}
# Подключение и запрос токена         
response = requests.post(url, verify=False, json=login_payload)             
x = response.json()

# Токен для авторизации в API
token = x['data']['session_token']                                          
# Правило дискавера дисков
if args.arg1 == 'discoverdisk':                                             
    url1 = "{0}/disks/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    # получение полного ответа о дисках в кривом JSON формате
    response1 = requests.get(url1, verify=False, headers=header)            
# колличество блоков в JSON ответе, на основе которого будет создаваться i тое колличество итемов
    rowcount = (response1.json()['endRow'])                                 
    arr1 = []
    for i in range(rowcount):
       arr1.insert(len(arr1),{"{#SLOT}":i,"{#ARRAYNAME}":response1.json()['data'][i]['array_name'],"{#TYPE}":response1.json()['data'][i]['type'],"{#SERIAL}":response1.json()['data'][i]['serial'],"{#MODEL}":response1.json()['data'][i]['model']})
    print((json.dumps(arr1)).replace(" ",""))
elif args.arg1 == 'diskstatus':
    url1 = "{0}/disks/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    print(response1.json()['data'][int(args.arg2)]['raid_state'])

# Правило дискавера fc
elif args.arg1 == 'discoverfc':                                            
    url1 = "{0}/fibre_channel_ports/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"{#FCSLOT}":i,"{#FCARRAYNAME}":response1.json()['data'][i]['array_name_or_serial'],"{#FCCONTR}":response1.json()['data'][i]['controller_name'],"{#FCPORTSNAME}":response1.json()['data'][i]['fc_port_name']})
    print((json.dumps(arr1)).replace(" ",""))
elif args.arg1 == 'fcstatus':
    url1 = "{0}/fibre_channel_ports/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['link_info']['link_status']
    print(result)

# Правило дискавера сетевых интерфейсов
elif args.arg1 == 'discovernet':                                            
    url1 = "{0}/network_interfaces/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"{#NETSLOT}":i,"{#NETARRAYNAME}":response1.json()['data'][i]['array_name_or_serial'],"{#NETCONTR}":response1.json()['data'][i]['controller_name'],"{#NETPORTSNAME}":response1.json()['data'][i]['name']})
    print((json.dumps(arr1)).replace(" ",""))
elif args.arg1 == 'netstatus':
    url1 = "{0}/network_interfaces/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['link_status']
    print(result)     
elif args.arg1 == 'netlinkspeed':
    url1 = "{0}/network_interfaces/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['link_speed']
    print(result)
    
    # Правило дискавера состояния полок
elif args.arg1 == 'discovershelve':                                         
    url1 = "{0}/shelves/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    rowcount = (response1.json()['endRow'])
    arr1 = []
    for i in range(rowcount):
        arr1.insert(len(arr1),{"{#SHSLOT}":i,"{#SHARRAYNAME}":response1.json()['data'][i]['array_name']})
    print((json.dumps(arr1)).replace(" ",""))
elif args.arg1 == 'shpsustatus':
    url1 = "{0}/shelves/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['psu_overall_status']
    print(result)     
elif args.arg1 == 'shfanstatus':
    url1 = "{0}/shelves/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['fan_overall_status']
    print(result)
elif args.arg1 == 'shtempstatus':
    url1 = "{0}/shelves/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['temp_overall_status']
    print(result)
    
    
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
       arr1.insert(len(arr1),{"{#POOLSLOT}":i,"{#POOLARRAYNAME}":response1.json()['data'][i]['name'],"{#POOLCAPACITY}":cab1})
    print((json.dumps(arr1)).replace(" ",""))
elif args.arg1 == 'poolsusage':
    url1 = "{0}/pools/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['usage'] / 1024 / 1024 / 1024 / 1024
    print(format(result,'.2f'))
elif args.arg1 == 'poolsfreespace':
    url1 = "{0}/pools/detail".format(args.dnsname)
    header = {'X-Auth-Token': token}
    response1 = requests.get(url1, verify=False, headers=header)
    result = response1.json()['data'][int(args.arg2)]['free_space'] / 1024 / 1024 / 1024 / 1024
    print(format(result,'.2f')) 
