# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)


class Intelligence(object):
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

        payload = {
            'filters': [],
            'paginate': True,
            'pagination': {"page": 1, "pageSize": 20}
        }
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
        data = [intelligence for intelligence in intelligence_list if intelligence['content'] == name][0]
        return data['intelligence']

    def delete(self, id):
        uri = self._console_url + '/__api/security/intelligence/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, json=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
