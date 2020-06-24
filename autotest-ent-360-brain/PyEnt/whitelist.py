# -*- coding:utf-8 -*-

import json
from ._internal_utils import status_code_check, response_status_check

class GlobalWhitelist(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    print session

    def list(self):
        '''
        Get all global whitelist.
        :return:  all alobal whitelist.
        '''
        uri = self._console_url + '/__api/security/global-whitelists?local=zh_cn'
        payload = {
            "filters": [],
            "paginate": "true",
            "pagination": {
                "page": 1,
                "pageSize": 1000
            },
            "sorts": []
        }
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def get_by_id(self, id):
        '''
        Get the signal whitelist value .
        :param id: id
        :return: the whitelist of id .
        '''
        uri = self._console_url + '/__api/security/global-whitelist/' + str(id)
        payload = {'locale': 'zh_cn'}
        response = self._session.get(uri, params=payload, verify=False)
        print response.url
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def create_by_data(self, data):
        '''

        :param data:
        :return:
        '''
        #print data
        uri = self._console_url + '/__api/security/global-whitelist?locale=zh_cn'
        response = self._session.post(uri, data=data, verify=False)
        response_content = json.loads(response.content)
        #print response_content['statusCode'], response_content['messages'][0]
        status_code_check(response.status_code, 200)
        #print response.status_code
        print response_content['messages'][0]
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages'][0]

    def create_by_file(self, whitelist_file):
        '''
        Create whitelist by file
        :return:
        '''
        #print 'hello'
        with open(whitelist_file) as pf:
            content = pf.read().strip()
            print content
        whitelist_dict = json.loads(content)
        return self.create_by_data(whitelist_dict)

    def create(self, type=None, contentType=None, content=None, description=None, data=None, **kwargs):
        '''
        Create whitelist data.
        :param id:
        :param type: whitelist type, required.
        :param contentType:  whitelist contentTpye, required
        :param content: whitelist content, required.
        :param description: description
        :param kwargs:  other opts
        :return:
        '''
        type=kwargs.pop('type', None)
        print data
        if data:
            create_data = data
        else:
            assert type
            assert contentType
            assert content
            create_data = {
                'type': type,
                'contentType': contentType,
                'content': content
            }
        if description:
            create_data['descripition'] = description
        print 'create data is:', create_data
        print self.create_by_data(create_data)
        #return self.create_by_data(create_data)

    def update_globalwhitelist(self, id, content):
        list_whitelist = self.list()
        id_info = self.get_by_id(id)
        uri = self._console_url + '/__api/security/global-whitelist/' + id + '?locale=zh_cn'
        payload = {
            "contentType": id_info['contentType'],
            "content": str(content),
            "id": id,
            "type": id_info['type'],
            "description": ""
        }
        response = self._session.put(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)

    def delete(self, id):
        '''
        Delete the id whitelist.
        :param id: id
        :return:
        '''

        uri = self._console_url + '/__api/security/global-whitelist/'+ id + '?locale=zh_cn'
        #print uri
        response = self._session.delete(uri, headers={'Content-Type': 'application/json;charset=UTF-8'}, verify=False)
        #print response.status_code
        status_code_check(response.status_code, 200)

    def delete_all(self):
        '''
        Delete all global whitelist.
        :return:
        '''
        whitelist_list = self.list()
        for whitelist in whitelist_list:
            #print whitelist['id']
            try:
                self.delete(whitelist['id'])
            except:
                pass

    def export(self, id, local_file):
        '''
        Export the global whitelist.
        :param id: whitelist id.
        :return:
        '''
        uri = self._console_url + '/__public/security/global-whitelist/export/' + id + '?proxy=true'
        #print uri
        response = self._session.get(uri, verify=False)
        #print response.status_code
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def upload_check(self, file):
        '''
        Check the upload file.
        :param file:
        :return:
        '''
        uri = self._console_url + '/__api/security/global-whitelist/import/check?locale=zh_cn'
        file = {'tempFile': open(file, 'rb')}
        response = self._session.post(uri, files=file, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #print response.status_code
        #print response_content['statusCode']
        #print response_content['data']['fileName']
        print "Checking the upload whitelist file is success!"
        return response_content['data']

    def upload_whitelist_file(self, local_file):
        '''
        Upload the whitelist file.
        :param local_file:
        :return: messages
        '''
        uri = self._console_url + '/__api/security/global-whitelist/import/insert?locale=zh_cn'
        data = self.upload_check(local_file)['fileName']
        #print 'data is : ', data
        payload = {'data': data }
        response = self._session.post(uri, data=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        print response_content['messages'][0]
        return response_content['messages'][0]

    def query_by_content(self, content):
        '''
        Query the ioc whitelist by ioc content.
        :param content:  content
        :return: ioc whitelist info list.
        '''
        uri = self._console_url + '/__api/security/global-whitelists'
        payload = {
            "filters": [{"field": "content", "operator": "like", "value": content}],
            "paginate": True,
            "pagination": {"page": "1", "pageSize": "1000" },
            "sorts": []
        }
        response = self._session.post(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def export(self, local_file):
        '''
        :return:
        '''
        uri = self._console_url + '/__public/security/global-whitelist/export/all?proxy=true&locale=en'
        response = self._session.get(uri, verify=False)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def export_global_whitelist_file(self, local_file, id):
        '''
        Export the intelligence whitelist by id.
        :param id: intelligence whitelist id.
        :return:
        '''
        uri = self._console_url + '/__public/security/global-whitelist/export/' + str(id) + '?proxy=true&locale=zh_cn'
        payload = {"proxy": True, "locale": "zh_cn"}
        response = self._session.get(uri, json=payload, verify=False)
        print uri
        print response.url
        status_code_check(response.status_code, 200)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def import_global_whitelist_check(self, local_file):
        '''
        Check the exported global whitelist file.
        :param local_file: the path of local global whitelist file
        :return: None
        '''
        uri = self._console_url + '/__api/security/global-whitelist/import/check' + '?locale=zh_cn'
        files = {'tempFile': open(local_file, 'rb')}
        response = self._session.post(uri, files=files, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def import_global_whitelist_file(self, local_file):
        '''
        Import the exported global whitelist file.
        :param local_file: the path of local global whitelist file
        :return: None
        '''
        url = self._console_url + '/__api/security/global-whitelist/import/insert'
        #data = self.import_intelligence_whitelist_check(local_file)
        #file_id = data['fileName']
        #print file_id
        file_id = self.import_global_whitelist_check(local_file)['fileName']
        payload ={"data": file_id}
        response = self._session.post(url, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        print response_content['messages']

class IntelligenceWhitelist(object):
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
        '''
        Get all intelligence whitelist.
        :return: list
        '''
        uri = self._console_url + '/__api/security/ioc-whitelists' + '?locale=zh_cn'
        payload ={
            "filters": [],
            "paginate": True,
            "pagination": {"page": 1, "pageSize": 1000},
            "sorts": []
        }
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def get_by_id(self, id):
        '''
        Get tje intelligence whitelist by id.
        :param id:
        :return: info list
        '''
        uri = self._console_url + '/__api/security/ioc-whitelist/' + str(id)
        payload = {"locale": "zh_cn"}
        response = self._session.get(uri, params=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'][0])
        return response_content['data']

    def create_iocwhitelist_by_data(self, data):
        '''
        Create ioc whitelist by data
        :return:
        '''
        print data
        ioc_list = self.list()
        array_ioc = []
        for item in ioc_list:
            array_ioc.append(item['content'])
        if data['content'] in array_ioc:
            print "Ioc whitelist", data['content'], "is already exsit."
        else:
            uri = self._console_url + '/__api/security/ioc-whitelist'
            print data
            response = self._session.post(uri, json=data, verify=False)
            print response.url
            print response.status_code
            response_content = json.loads(response.content)
            status_code_check(response.status_code, 200)
            response_status_check(response_content['statusCode'], 0, response_content['messages'][0])

    def create_iocwhitelist_by_file(self, file):
        '''
        Create ioc whitelist by local_file.
        :param file:
        :return:
        '''
        with open(file) as pf:
            content = pf.read().strip()
        content = json.loads(content)
        self.create_iocwhitelist_by_data(data=content)

    def update_iocwhitelist(self, id, content):
        list_whitelist = self.list()
        id_info = self.get_by_id(id)
        uri = self._console_url + '/__api/security/ioc-whitelist/' + id + '?locale=zh_cn'
        payload = {
            "contentType": id_info['contentType'],
            "content": str(content),
            "id": id,
            "type": id_info['type'],
            "description": ""
        }
        response = self._session.put(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)

    def query_by_content(self, content):
        '''
        Query the ioc whitelist by ioc content.
        :param content:  content
        :return: ioc whitelist info list.
        '''
        uri = self._console_url + '/__api/security/ioc-whitelists'
        payload = {
            "filters": [{"field": "content", "operator": "like", "value": content}],
            "paginate": True,
            "pagination": {"page": "1", "pageSize": "1000" },
            "sorts": []
        }
        response = self._session.post(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def delete(self, id):
        '''
        Delete the ioc whitelist info by id .
        :param id:  ioc whitelist id.
        :return: None
        '''
        uri = self._console_url + '/__api/security/ioc-whitelist/' + id + '?locale=en'
        response = self._session.delete(uri, headers={"Content-Type": "application/json"}, verify=False)
        #print response.url
        #print response.status_code
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'][0])

    def delete_all(self):
        '''
        Delete all ioc whitelist.
        :return: None
        '''
        ioc_list = self.list()
        for item in ioc_list:
            self.delete(item['id'])

    def export(self, local_file):
        '''
        :return:
        '''
        uri = self._console_url + '/__public/security/ioc-whitelist/export/all?proxy=true&locale=en'
        response = self._session.get(uri, verify=False)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def export_intelligence_whitelist_file(self, local_file, id):
        '''
        Export the intelligence whitelist by id.
        :param id: intelligence whitelist id.
        :return:
        '''
        uri = self._console_url + '/__public/security/ioc-whitelist/export/' + str(id) + '?proxy=true&locale=zh_cn'
        payload = {"proxy": True, "locale": "zh_cn"}
        response = self._session.get(uri, json=payload, verify=False)
        print uri
        print response.url
        status_code_check(response.status_code, 200)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def import_intelligence_whitelist_check(self, local_file):
        '''
        Check the exported intelligence whitelist file.
        :param local_file: the path of local intelligence whitelist file
        :return: None
        '''
        uri = self._console_url + '/__api/security/ioc-whitelist/import/check' + '?locale=zh_cn'
        files = {'tempFile': open(local_file, 'rb')}
        response = self._session.post(uri, files=files, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def import_intelligence_whitelist_file(self, local_file):
        '''
        Import the exported intelligence whitelist file.
        :param local_file: the path of local intelligence whitelist file
        :return: None
        '''
        url = self._console_url + '/__api/security/ioc-whitelist/import/insert'
        #data = self.import_intelligence_whitelist_check(local_file)
        #file_id = data['fileName']
        #print file_id
        file_id = self.import_intelligence_whitelist_check(local_file)['fileName']
        payload ={"data": file_id}
        response = self._session.post(url, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        print response_content['messages']










