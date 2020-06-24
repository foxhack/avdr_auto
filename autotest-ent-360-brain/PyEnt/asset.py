# -*- coding: utf-8 -*-

import json
import os
import xlrd

from ._internal_utils import status_code_check, response_status_check
from .assettype import AssetType
from assetview import AssetBusiness

import logging
log = logging.getLogger(__name__)


class Asset(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def list(self):
        """List all assets
        
        :return: asset list
        """

        uri = self._console_url + '/__api/asset/query'
        data = {
            "filters": [
                {
                    "field": "asset_type_id_path",
                    "operator": "like",
                    "value": "/"
                }
            ]
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def get(self, id):
        """Get asset by id
        
        :param id: asset id
        :return: asset info dict
        """

        asset_list = self.list()
        return [asset for asset in asset_list if asset['asset_id'] == id][0]

    def get_by_name(self, name):
        """Get asset by name
        
        :param name: asset name
        :return: asset info dict
        """

        asset_list = self.list()
        return [asset for asset in asset_list if asset['asset_name'] == name][0]

    def create_by_data(self, data):
        """Create asset
        
        :param data: asset data
        :return: asset id
        """

        uri = self._console_url + '/__api/asset/add'
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['id']

    def create(self, asset_name=None, ip_address=None, asset_type_name=None, asset_owner='', business_name=None, data=None, **kwargs):
        """Create asset
        
        :param asset_name: asset name, required
        :param ip_address: asset ip address, required
        :param asset_type_name: asset type name, got asset type id from it, required
        :param data: asset data
        :param kwargs: other attrs
        :return: asset id
        """

        if data:
            create_data = data
        else:
            assert asset_name
            assert ip_address
            assert asset_type_name
            _asset_type = AssetType(self._console_url, self._session)
            _asset_business = AssetBusiness(self._console_url, self._session)
            asset_type_id = _asset_type.get_by_name(asset_type_name)['id']

            create_data = {
                "asset_name": asset_name,
                "ip_address": ip_address,
                "asset_type_id": asset_type_id,
                "asset_type_name": asset_type_name,
                "important": 0,
                "asset_code": "",
                "status": 3,
                "responsible_id": asset_owner,
                "mac": "",
                "user_id": "",
                "phone": "",
                "manufacturer_id": "",
                "version": "",
                "description": "",
                "business_ids": "3",
                "business_names": "业务系统",
                "domain_ids": "2",
                "domain_names": "安全域",
                "location_ids": "4",
                "location_names": "物理位置",
                "organization_ids": "",
                "organization_names": "",
                "confidentiality": 0,
                "integrity": 0,
                "availability": 0,
                "category_tags": [],
                "rule_tags": [],
                "customer_tags": ["test"],
                "asset_category": "host"
            }
            #kwargs handler
            status = kwargs.pop('status', None)
            if status:
                create_data['status'] = status

            if business_name:
                asset_business_id = _asset_business.get_by_name(business_name)['id']
                create_data['business_names'] = business_name
                create_data['business_ids'] = asset_business_id

        return self.create_by_data(create_data)

    def update(self, id, data=None, **kwargs):
        """Update asset
        
        :param id: asset id
        :param data: asset data
        :param kwargs: optional arguments to update asset
        :return: None
        """

        uri = self._console_url + '/__api/asset/' + id
        if data:
            update_data = data
        else:
            update_data = self.get(id)
            asset_name = kwargs.pop('asset_name', None)
            ip_address = kwargs.pop('ip_address', None)
            important = kwargs.pop('important', None)
            if asset_name:
                update_data['asset_name'] = asset_name
            if ip_address:
                update_data['ip_address'] = ip_address
            if important:
                update_data['important'] = important
            #other kwargs handler

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        """Delete asset by id
        
        :param id: asset id
        :return: None
        """

        uri = self._console_url + '/__api/asset/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        status_code_check(response.status_code, 200)

    def delete_all(self):
        """Delete all assets

        :return: None
        """

        asset_list = self.list()
        for asset in asset_list:
            try:
                self.delete(asset['asset_id'])
            except Exception as ex:
                pass

    def import_asset(self, local_file, strategy='skip'):
        """Import asset
        
        :param local_file: local asset file to import, xlsx format
        :param strategy: update strategy, default is skip
        :return: import uri
        """
        uri = self._console_url + '/__api/asset/import/check'
        file_name = os.path.basename(local_file)
        files = {'tempFile': (file_name, open(local_file, 'rb'), 'application/octet-stream')}
        response = self._session.post(uri, files=files)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        b_warn = len(response_content['data']['warnings'])
        uri = self._console_url + '/__api/asset/import/'
        if b_warn:
            strategies = {
                'skip': 'skip',
                'update': 'update'
            }
            strategy = strategies.get(strategy, 'skip')
            uri = uri + strategy
        else:
            uri = uri + 'insert'
        payload = {'data': response_content['data']['assets']}
        response = self._session.post(uri, json=payload)
        status_code_check(response.status_code, 200)
        return uri

    def get_score(self, ip):
        """Get asset score
        
        :param ip: asset ip
        :return: asset score info
        """
        uri = self._console_url + '/api/node/asset/score/recent'
        payload = {"bool": {"must": [{"term": {"dim_scope": 1}}, {"term": {"score_ip_list": ip}}]}}
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_score_by_dimension_scope(self, dim_scope="3", keyword="3"):
        """
        Get score fromm different scope: asset ip, business
        """
        dim_scope_type_mapping = {
            "1": "score_ip_list",
            "2": "related_asset_domain_id",
            "3": "related_asset_business_id",
            "4": "related_asset_location_id",
            "5": "related_asset_organization_id"
        }
        uri = self._console_url + '/__api/asset/score/recent'
        data = {
            "bool": {
                "must": [
                    {
                        "term": {
                            "dim_scope": int(dim_scope)
                        }
                    },
                    {
                        "term": {
                            dim_scope_type_mapping[str(dim_scope)]: keyword
                        }
                    }
                ]
            }
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def query_risk_score_info(self, condition=None):
        """
        """
        uri = self._console_url + "/__api/discover/search"
        data = {
            "source": "security_assess_based_score",
            "timeFilter": "创建时间 >=now/d-1d AND 创建时间 <now/d+1d",
            "filter": "%s" % ( condition if condition else "" ),
            "search": {
                "from": 0,
                "size": 30,
                "columns": [
                    {
                        "field": "create_time",
                        "order": "desc",
                        "highlight": True
                    }
                ]
            }
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]["search"]

    def get_risk_asset_by_business(self, business_id=None):
        """
        """
        uri = self._console_url + "/__api/asset/view/query"
        data = {
            "paginate": True,
            "pagination": {
                "page": 1,
                "pageSize": 20
            },
            "key": "",
            "field": "",
            "filters": [
                {
                    "field": "business_id",
                    "operator": "like",
                    "value": "/"
                }
            ]
        }

        if business_id:
            data['filters'][0]['value'] = business_id

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]["list"]

    def query(self, condition=None):
        """
        Query event logs count with condition
        """
        uri = self._console_url + "/__api/discover/search"
        data = {
            "source": "asset",
            "timeFilter": "创建时间 >=now/d-1d AND 创建时间 <now/d+1d",
            "filter": "%s" % ( condition if condition else "" ),
            "search": {
                "from": 0,
                "size": 10,
                "columns": [
                    {
                        "field": "create_time",
                        "order": None,
                        "highlight": True
                    }
                ]
            }
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]["search"]["total"]

    # def search_asset(self, search_type, search_keyword):
    #     """
    #     Query asset by different type
    #     search_type: 'asset_name', 'general_ip', 'responsible_id'
    #
    #     """
    #     uri = self._console_url + "/__api/asset/search"
    #     data = {
    #         "index": "asset_confirmed",
    #         "key": search_keyword,
    #         "field": search_type,
    #         "paginate": True,
    #         "pagination": {
    #             "page": 1,
    #             "pageSize": 20
    #         }
    #     }
    #     response = self._session.post(uri, json=data)
    #     response_content = json.loads(response.content)
    #     #print "response.url: %s " % response.url
    #
    #     status_code_check(response.status_code, 200)
    #     response_status_check(response_content['statusCode'], 0, response_content['messages'])
    #     return response_content["data"]["list"]
    #
    #
    # def search_asset_by_tag(self, tags):
    #     """
    #     """
    #     uri = self._console_url + "/__api/asset/search/tags"
    #     data = {
    #         "index": "asset_confirmed",
    #         "key": tags
    #     }
    #
    #     response = self._session.post(uri, json=data)
    #     response_content = json.loads(response.content)
    #
    #     status_code_check(response.status_code, 200)
    #     response_status_check(response_content['statusCode'], 0, response_content['messages'])
    #     return response_content["data"]["list"]

    def add_custom_tag(self, tag):
        """
        """
        uri = self._console_url + "/__api/asset/tag"
        data = {
            "name": tag
        }
        
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])



    ######### AVDR同步资产后##########
    def search_asset_avdr(self, search_type, search_value, tags=""):
        """
        :param search_type:

        :param search_keyword:
        :return:
        根据IP/资产名称/负责人搜索出资产
        """
        uri = self._console_url + "/__api/asset/avdr/v1/asset/query"
        datas = {
	            "paginate": True,
	            "pagination": {
		                        "page": 1,
		                        "pageSize": 10
	                            },
	            "tags": tags,
	            "filter": {
		        "field": search_type,
		        "value": search_value
	                        }
                }
        # response = self._session.post(uri, data=json.dumps(datas))
        response = self._session.post(uri, json=datas)
        response_content = response.json()

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']


    def search_asset_tag_avdr(self,tags):
        """
        仅根据tag查询资产
        """
        uri = self._console_url + "/__api/asset/avdr/v1/asset/query"
        data = {
	            "paginate": True,
	            "pagination": {
		        "page": 1,
		        "pageSize": 10
	            },
	            "tags": tags
                }
        response = self._session.post(uri,json=data)
        response_content = response.json()

        status_code_check(response.status_code, 200)
        response_status_check(response_content["statusCode"], 0, response_content['messages'])
        return response_content['data']['list']


    def clear_asset(self):
        """
        清空搜索资产
        :return:
        """
        uri = self._console_url + "/__api/asset/clear"
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers= header)
        response_content = response.json()
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages']

    def import_asset(self, local_file):
        #### 先调用check接口，查看导入文件中的资产信息是否已经存在
        print "lujing:%s" % os.path.abspath(local_file)
        file_name = os.path.basename(local_file)
        file = {
                'tempFile':open(local_file, 'rb'),
                'Content-Disposition':'form-data',
                'Content-Type':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'filename':file_name
                }
        uri_check = self._console_url + "/__api/asset/import/check?locale=zh_ch"
        response_check = self._session.post(uri_check, files=file)
        response_content_check = response_check.json()
        #print response_content_check
        warn_text = response_content_check['data']['warnings']

        ###### 根据check结果，判断是"忽略"/"覆盖"，分别调用对应接口skip/insert
        uri_import = self._console_url + "/__api/asset/import/"
        if warn_text:
            uri_import = uri_import + 'skip'
        else:
            uri_import = uri_import + 'insert'
        asset_lists = response_content_check['data']['assets']
        data_insert = {
            'data': asset_lists
        }
        response = self._session.post(uri_import, json=data_insert)
        response_content = response.json()

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response.url


    def add_tag(self, tags, asset_ip, asset_name, asset_id, id1, **kargs):
        """
        为资产添加标签，参数如下，其中id1是资产的"_id": "***"
        :param tags:
        :param asset_ip:
        :param asset_name:
        :param asset_id:
        :param id1:
        :return:
        """
        uri = self._console_url + "/__api/asset/update"
        data = {
                "customer_tags": tags,
                "ip_address": asset_ip,
                "asset_name": asset_name,
                "asset_id": asset_id,
                "_id": id1
            }
        response = self._session.put(uri, json=data)
        response_content = response.json()

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']


    def get_tags(self):
        """
        获取所有的标签信息
        :return:
        """
        uri = self._console_url + "/__api/asset/tag/query"
        response = self._session.post(uri)
        response_content = response.json()

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def export_assets(self, file_path):
        uri = self._console_url + '/__api/asset/export?proxy=true&locale=zh_cn'
        response = self._session.get(uri)
        with open(file_path, 'wb') as f:
            f.write(response.content)
        s = xlrd.open_workbook(file_path)
        sheet = s.sheet_by_index(0)
        ip_lists = sheet.col_values(1, 1, 4)

        status_code_check(response.status_code, 200)
        return ip_lists



