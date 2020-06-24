#!/usr/bin/python
# -*- coding=utf-8 -*-




#from PyHes import PyHes

#from PyEnt._internal_utils import generate_filter_condition, generate_filter_group, get_local_ipPyEnt._internal_utils
#import PyEnt._internal_util
from PyEnt import PyEnt
from PyEnt.sender import Sender
import json
import time
from PyEnt import Asset
import os



host = '172.16.100.244'
username = 'admin'
password = 'HanS!gh5#NT'
#password = 'S3cur!ty'
console_url = "https://{host}".format(host=host)
console_url_http = "http://{host}".format(host=host)
#print console_url_http


#hes = PyEnt(console_url, username=username, password=password)
p = PyEnt(console_url, username=username, password=password)


# res = p.module_exec('Asset', 'search_asset', search_type = "general_ip", search_keyword = "172.16.200.1")
# print res

#先清空资产
#res1 = p.module_exec('Asset', 'clear_asset')

#导入资产
path_local = os.getcwd()
print path_local
res2 = p.module_exec('Asset', 'export_assets', file_path=path_local + "asset_export.xlsx")
print res2