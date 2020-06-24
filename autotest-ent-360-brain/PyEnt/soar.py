# -*- coding: utf-8 -*-

import json
import copy
from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)


class Automation(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self.header = {'Content-Type': 'application/json;charset=UTF-8'}

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def search(self, name="", tag=""):
        """
        List all automations

        """

        uri = self._console_url + '/__api/soar/v1/automations/search'
        data = {
            "filter": name,
            "search": {
                "from": 0,
                "size": 20
            },
            "sort": {
                "field": "updateTime",
                "order": "desc"
            }
        }

        if tag:
            data['tag'] = tag

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def create(self, name, tags=[], is_condition=False):
        """
        create new automation with default setting

        """
        uri = self._console_url + '/__api/soar/v1/automations'
        default_output = [{"selection":[{"value":"1","description":"111"},{"value":"2","description":"222"}]}]
        data = {
            "name": name,
            "conditional": is_condition,
            "description": "test automation",
            "tags": tags if tags else [],
            "script": "pass",
            "inputs": [],
            "outputs": default_output if is_condition else []
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['id']

    def get_all_tags(self):
        """
        """
        uri = self._console_url + '/__api/soar/v1/tags?type=automation'
        
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def delete(self, auto_id):
        """
        """
        uri = self._console_url + '/__api/soar/v1/automations/%s' % auto_id

        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all(self):
        """
        """
        data = self.search()
        for i in data:
            if not 'sysId' in i:
                self.delete(i['id'])

    def get_detail(self, auto_id):
        """
        """
        uri = self._console_url + '/__api/soar/v1/automations/%s' % auto_id

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']


class Playbook(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self.header = {'Content-Type': 'application/json'}

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def search(self, name="", tag=""):
        """
        """

        uri = self._console_url + '/__api/soar/v1/playbooks/search'
        data = {
            "filter": name,
            "sort": {
                "field": "updateTime",
                "order": "desc"
            },
            "page": {
                "pageNumber": 1,
                "pageSize": 10
            }
        }

        if tag:
            data['tag'] = tag

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def create_manual_action(self):
        """
        """
        return {
            "name": "manual action",
            "description": "test",
            "actionType": 1,
            "playbookId": "playbook_id",
            "manualType": 0,
            "owner": "FIKVIZS30007",
            "showCaseEnable": False,
            "outputs": [],
            "inputs": [],
            "questions": [],
            "outputPoints": [
                {
                    "value": 2
                }
            ],
            "inputPoints": [
                {
                    "value": "inputPoints"
                }
            ],
            "position": {
                "x": 1409,
                "y": 1336
            },
            "_editing": False,
            "_newForm": False,
            "__focus": False,
            "id": 2,
            "actionId": 2,
            "index": "1",
            "height": 88,
            "width": 240,
            "sla": [],
            "refresh": False
        }

    def create(self, name, action, tags=[]):
        """
        """
        uri = self._console_url + '/__api/soar/v1/playbooks'
        data = {
            "tags": tags if tags else [],
            "name": name,
            "description": "test playbook",
            "_ifNew": True,
            "inputs": [],
            "outputs": [],
            "timers": [],
            "edges": [
                {
                    "fromNode": "1",
                    "toNode": "2",
                    "fromOutput": "1",
                    "toInput": 2
                },
                {
                    "fromNode": "2",
                    "toNode": "3",
                    "fromOutput": 2,
                    "toInput": 3
                }
            ],
            "nodes": [
                {
                    "id": 1,
                    "actionId": 1,
                    "name": "开始",
                    "actionType": 4,
                    "position": {
                        "x": 1070,
                        "y": 301
                    },
                    "inputPoints": [
                        {
                            "value": "1"
                        }
                    ],
                    "outputPoints": [
                        {
                            "value": "1"
                        }
                    ],
                    "index": "0",
                    "height": 60,
                    "width": 168
                },
                {
                    "id": 2,
                    # "inputs": [],
                    # "outputs":[],
                    # "questions":[],
                    # "name":"ABC",
                    # "description":"test",
                    # "conditional":False,
                    # "tags": ["test"],
                    # "script":"a=1",
                    # "createTime":1579060225000,
                    # "updateTime":1579060225000,
                    # "owner":"FIKVIZS30007",
                    # "automationId":"953e0473be6e4395b88b8ae02df282d9",
                    "actionType":0,
                    "__focus":False,
                    "position":{
                        "x": 1070,
                        "y": 426
                    },
                    "actionId": 2,
                    "index": "1",
                    "_newForm": False,
                    "outputPoints": [
                        {
                            "value": 2
                        }
                    ],
                    "inputPoints": [
                        {
                            "value": 2
                        }
                    ],
                    "height": 88,
                    "width": 240,
                    "timeout": [

                    ],
                    "refresh":False,
                    "_editing":False
                },
                {
                    "inputPoints": [
                        {
                            "value": 3
                        }
                    ],
                    "outputPoints": [
                        {
                            "value": 3
                        }
                    ],
                    "actionType": 5,
                    "name": "结束",
                    "position": {
                        "x": 1070,
                        "y": 551
                    },
                    "id": 3,
                    "actionId": 3,
                    "index": "2",
                    "_newForm": True,
                    "height": 60,
                    "width": 168
                }
            ]
        }

        if 'manualType' in action:
            data['nodes'][1] = action
            data['edges'][0]['toInput'] = 'inputPoints'
        else:
            tmp = copy.deepcopy(action)
            data['nodes'][1]['automationId'] = tmp['id']
            del tmp['id']
            data['nodes'][1].update(tmp)

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']


    def get_all_tags(self):
        """
        """
        uri = self._console_url + '/__api/soar/v1/tags?type=playbook'
        
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def get_manual_action(self):
        """
        """
        name = ""
        uri = self._console_url + '/__api/soar/v1/playbooks/actions/manual?name=%s' % name
        
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def delete(self, playbook_id):
        """
        """
        uri = self._console_url + '/__api/soar/v1/playbooks/%s' % playbook_id

        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all(self):
        """
        """
        data = self.search()
        for i in data:
            if not 'sysId' in i:
                self.delete(i['id'])

    def get_detail(self, playbook_id):
        """
        """
        uri = self._console_url + '/__api/soar/v1/playbooks/%s' % playbook_id

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def trigger(self, playbook_id, from_by=1):
        '''
            Trigger the playbook
        '''
        uri = self._console_url + '/__api/soar/v1/playbooks/%s/trigger' % playbook_id
        data = {
            "from": from_by
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

class CaseManage(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self.header = {'Content-Type': 'application/json'}

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def search(self, filters=""):
        """
        """
        uri = self._console_url + '/__api/soar/v1/cases/list'
        payload = {
            "source": "soar_case",
            "search":{
                "from": 0,
                "size": 500
            },
           "timeFilter":  u"开始时间 >=now-30d AND 开始时间 <=now",
            "filter": filters
        }
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['data']

    def get_detail(self, case_id):
        '''

        :return:
        '''
        uri = self._console_url + '/__api/soar/v1/cases/%s/detail' % case_id
        print uri
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def get_task_list(self, case_id):
        '''
        Get the task list
        :param case_id: id
        :return:
        '''
        uri = self._console_url + '/__api/soar/v1/cases/%s/tasks/list' % case_id
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def delete(self, case_id):
        '''
        Delete case.
        :param id:
        :return:
        '''
        uri = self._console_url + '/__api/soar/v1/cases/%s' % case_id
        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all(self):
        case_list = self.search()
        for i in case_list:
            self.delete(i['_id'])