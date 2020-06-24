# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)


class Information(object):
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
        """List all intelligences

        :return: intelligence list
        """

        payload = {'paginate': False, 'pagination': {}, 'sorts': []}
        uri = self._console_url + '/__api/security/intelligence/query'

        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def get(self, id):
        """Get intelligence by id

        :param id: intelligence id
        :return: intelligence info dict
        """

        uri = self._console_url + '/__api/security/intelligence/' + id

        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['intelligence']

    def get_by_name(self, name):
        """Get intelligence by name

        :param name: intelligence name
        :return: intelligence info dict
        """

        intelligence_list = self.list()
        return [intelligence for intelligence in intelligence_list if intelligence['content'] == name][0]

    def test_add(self):
        uri = self._console_url + '/__api/security/intelligence'
        payload = {"content":"2.2.2.1-2.2.2.32", "contentType":"couple", "groupId":"WOGNE0IG027c"}
        response = self._session.post(uri,json=payload)
        print response.status_code
        print response.content

    def create_by_data(self, data):
        '''
        Create information .
        :param data: dict
        :return: None
        '''

        uri = self._console_url + '/__api/security/intelligence'
        response = self._session.post(uri, json=data, headers={"Content-Type": "application/json;charset=UTF-8"})
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def create_by_filecontent(self, data):
        '''
        Create information .
        :param data: dict
        :return: None
        '''

        uri = self._console_url + '/__api/security/intelligence'
        if (type(data) != type(dict)):
            data = json.loads(data)
            print type(data)

        response = self._session.post(uri, json=data, headers={"Content-Type": "application/json;charset=UTF-8"})
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def update(self, id, data, **kwargs):
        '''
        Modify the data.
        :param data:
        :return: None
        '''
        uri = self._console_url + '/__api/security/intelligence/' + str(id)
        if data:
            update_data = data
        else:
            update_data = self.get(id=id)
            content = kwargs.pop('content')
            if content:
                update_data['content'] = content
        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def update_by_filecontent(self, id, data, **kwargs):
        '''
        Modify the data.
        :param data:
        :return: None
        '''
        uri = self._console_url + '/__api/security/intelligence/' + str(id)
        if data:
            update_data = data
        else:
            update_data = self.get(id=id)
            content = kwargs.pop('content')
            if content:
                update_data['content'] = content
        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        '''
        Dlete information by id
        :param id: info id to be deleted
        :return: None
        '''

        uri = self._console_url + '/__api/security/intelligence/' + str(id)
        response = self._session.delete(uri, headers={"Content-Type": "application/json;charset=UTF-8"})
        print response.url
        print response.content
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all(self):
        '''
        Dlete all slected information.
        :return: None
        '''
        pass

    def query_by_content(self, content):
        '''
        Query the content
        :param content:
        :return:
        '''
        uri = self._console_url + '/__api/security/intelligence/query'
        payload = {"filters": [{"field": "content", "operator": "like", "value": content}]}
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        print response_content['data']['list']
        return response_content['data']['list']

    def query_by_idpath(self, idpath):
        '''
        Query the idpath and info list belong them.
        :param idpath: dir
        :return: list
        '''
        uri = self._console_url + '/__api/security/intelligence/query'
        payload = {"filters": [{"field": "idPath", "operator": "like", "value":idpath}]}
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #print response_content['data']['list']
        return response_content['data']['list']

    def export_all(self, local_file):
        '''
        Export the information file.
        :param local_file:
        :return:None
        '''
        uri = self._console_url + '/__public/security/intelligence/export/excel?proxy=true'
        response = self._session.get(uri)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

    def export(self, local_file, id):
        '''
        Export the information managenment.
        :param local_file:
        :param id: info id
        :return: None
        '''
        uri = self._console_url + '/security/intelligence/export/excel/' + str(id)
        payload = {"proxy": True}
        response = self._session.get(uri, json=payload)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)

