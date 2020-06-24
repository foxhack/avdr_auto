# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check, inTypeValue

import logging
log = logging.getLogger(__name__)

class InformationGroup(object):
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
        """Get all intelligence type

        :return: intelligence list
        """
        uri = self._console_url + '/__api/security/intelligenceGroup'
        response = self._session.get(uri, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        type_list = [x for x in response_content['data']['list'] if x['idPath'].count(r'/') != 0]

        return type_list

    def list_sub_type(self):
        """Get all intelligence sub type

        :return: intelligence sub type list
        """
        uri = self._console_url + '/__api/security/intelligenceGroup'

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        type_list = [x for x in response_content['data']['list'] if x['idPath'].count(r'/') == 3]

        return type_list


    def get(self, id):
        """Get intelligence type by id

        :param id: intelligence id
        :return: intelligence type
        """

        uri = self._console_url + '/__api/security/intelligenceGroup/' + str(id) + '?locale=zh_cn'
        response = self.session.get(uri, headers={"Content-Type": "application/json;charset=UTF-8"})
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_by_name(self, name):
        """Get event type by name

        :param name: type name
        :return:  event type
        """

        intelligence_type_list = self.list()
        intelligence_type_list.extend(self.list_sub_type())
        return [intelligence_type for intelligence_type in intelligence_type_list if intelligence_type['name'] == name][0]

    def create_informationGroup(self, name, type, parentid, inType):
        '''
        Create intelligence Group by data.
        :param name: intelligence group name
        :param type: intelligence group type
        :param parentid: the second level directory id
        :return: dict
        '''
        assert name
        assert type
        assert parentid
        assert inType
        list_group = self.list()
        typename = [x for x in list_group if x['name'] == name]
        if typename == []:
            uri = self._console_url + '/__api/security/intelligenceGroup'
            payload = {
                "name": name,
                "parentId": parentid,
                "id": "",
                "type": type,
                "intelligenceGroup": {"type": type},
                "intelligenceType": inTypeValue.get(inType),
                "inTypeSelected": {
                    "name": inType,
                    "value": inTypeValue.get(inType)
                },
                "sysId": "",
                "flag": False
            }
            #print payload
            response = self._session.post(uri, json=payload)
            status_code_check(response.status_code, 200)
            response_content = json.loads(response.content)
            return response_content['data']
        else:
            print 'The intelligence group is exist.'

    def delete_informationGroup_by_name(self, name):
        '''
        Add intelligence group.
        :return: list
        '''
        list_group = self.list()
        typename = [x for x in list_group if x['name'] == name]
        if typename == []:
            print 'name is not exsit.'
        else:
            id = typename[0]['id']
            uri =self._console_url + '/__api/security/intelligenceGroup/' + str(id)
            response = self._session.delete(uri, headers={"Content-Type": "application/json;charset=UTF-8"})
            response_content = json.loads(response.content)
            status_code_check(response.status_code, 200)
            response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def update(self, name1, name2):
        '''
        Update the intelligence Group by name.
        :param name: new name
        :return: dict info
        '''
        list_name = self.get_by_name(name=name1)
        id = list_name['id']
        uri = self._console_url + '/__api/security/intelligenceGroup/' + str(id)
        payload = {"id": id, "name": name2}
        response = self._session.put(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']






