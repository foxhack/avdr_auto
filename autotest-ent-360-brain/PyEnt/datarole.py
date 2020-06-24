import json

from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)


class DataRole(object):
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

    def add(self, name, dtype="all", content=None):
        """Add new data role
        :param dtype: 'all' or 'ip', default is 'all'
        :param content: when 'all' type, content is empty; when 'ip' type, content is 'subtype:value' like:
                     'single:1.1.1.1' or 'range:1.1.1.1-1.1.1.2' or 'mask:172.16.0.0/16'
        :return: data role id
        """
        uri = self._console_url + "/__api/system/esproxy"

        if dtype == 'all':
            value = '{"ips":[]}'
        else:
            value = '{"ips":[{"type":"%s", "content":"%s"}]}' % (content.split(':')[0], content.split(':')[1])

        data = {"name": name,
                "description": "test",
                "type": dtype,
                "data": value}

        print data

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['id']

    def list(self):
        """Get all data roles

        :return: data role list
        """

        payload = {'page': 1, 'size': 100}
        uri = self._console_url + "/__api/system/esproxy"

        response = self._session.get(uri, params=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def get(self, id):
        """Get role info by id
        
        :param id: role id
        :return: role info dict
        """
        uri = self._console_url + '/__api/system/esproxy' + id

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        print response.content
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def get_by_name(self, name):
        """Get role info by role name

        :param name: role name
        :return: role info dict
        """

        role_list = self.list()
        return [role for role in role_list if role['name'] == name][0]

    def update(self, id, dtype="all", content=None):
        """Update role

        :param id: role id
        :param dtype: role type
        :param content: role data
        :return: None
        """

        uri = self._console_url + '/__api/system/esproxy' + id

        update_role = self.get(id)

        if dtype == 'all':
            value = "{'ips':[]}"
        else:
            value = "{'ips':[{'type':'%s', 'content':'%s'}]}" % (content.split(':')[0], content.split(':')[1])

        data = {"name": update_role['name'],
                "description": "test",
                "type": dtype,
                "data": value}

        response = self._session.put(uri, json=data, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        """Delete role by id

        :param id: role id
        :return: None
        """

        uri = self._console_url + '/__api/system/roles/' + id

        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all(self):
        """Delete all roles

        :return: None
        """

        role_list = self.list()
        for role in role_list:
            try:
                self.delete(role['id'])
            except Exception as ex:
                print 'delete role exception', role['id']

