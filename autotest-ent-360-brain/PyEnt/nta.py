# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check, convert_date_time

from datetime import datetime, date, timedelta
import logging


log = logging.getLogger(__name__)


class NTA(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def query(self, parameter_def=None, parameter=None):
        """
        Query nta logs count with parameter
        """
        uri = self._console_url + "/__api/discover/search"
        if parameter:
            parameter_def = parameter_def + ' AND ' + parameter
        print parameter_def
        data = {
            "source": "event",
            "timeFilter": "发生时间 >=now/w AND 发生时间 <now/w+1w",
            "filter": "%s" % ( parameter_def ),
            "search": {
                "from": 0,
                "size": 20,
                "columns": [
                    {
                        "field": "occur_time",
                        "order": "desc",
                        "highlight": True
                    },
                    {
                        "field": "end_time",
                        "highlight": True
                    },
                    {
                        "field": "src_address",
                        "highlight": True
                    },
                    {
                        "field": "src_port",
                        "highlight": True
                    },
                    {
                        "field": "dst_address",
                        "highlight": True
                    },
                    {
                        "field": "dst_port",
                        "highlight": True
                    },
                    {
                        "field": "domain_name",
                        "highlight": True
                    },
                    {
                        "field": "request_Method",
                        "highlight": True
                    },
                    {
                        "field": "url",
                        "highlight": True
                    },
                    {
                        "field": "status_code",
                        "highlight": True
                    },
                    {
                        "field": "send_byte",
                        "highlight": True
                    },
                    {
                        "field": "receive_byte",
                        "highlight": True
                    },
                    {
                        "field": "protocol",
                        "highlight": True
                    },
                    {
                        "field": "referer",
                        "highlight": True
                    },
                    {
                        "field": "request_path",
                        "highlight": True
                    },
                    {
                        "field": "pcapstore",
                        "highlight": True
                    },
                    {
                        "field": "request",
                        "highlight": True
                    },
                    {
                        "field": "rsp",
                        "highlight": True
                    },
                    {
                        "field": "sensor_id",
                        "highlight": True
                    }
                ]
            }
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def config(self, pcapStore=None, pcapStoreIpFilter=None, pcapStorePortFilter=None, fileStore=None, fileStoreIpFilter=None, filePostfixFilter=None, filePostfixFilterType=None, ipFilter=None, ipFilterType=None, portFilter=None, portFilterType=None, alertPcapExtract=None, alertEnable=None, aiWeb=None):
        """
        config nta
        """
        uri = self._console_url + "/__api/nta/config"
        data = {
            "id": 1,
            "pcapStore": pcapStore,
            "pcapStoreIpFilter": pcapStoreIpFilter,
            "pcapStorePortFilter": pcapStorePortFilter,
            "fileStore": fileStore,
            "fileStoreIpFilter": fileStoreIpFilter,
            "filePostfixFilter": filePostfixFilter,
            "filePostfixFilterType": filePostfixFilterType,
            "ipFilter": ipFilter,
            "ipFilterType": ipFilterType,
            "portFilter": portFilter,
            "portFilterType": portFilterType,
            "alertPcapExtract": alertPcapExtract,
            "alertEnable": alertEnable,
            "aiWeb": aiWeb
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages']

    def list_ip(self, type=None):
        """
        query nta ip config
        """
        uri = self._console_url + "/__api/nta/config/ip/" + str(type)
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #result = [(item.get('id')) for item in response_content['data']]

        return response_content['data'][0]['id']

    def add_ip(self, desc=None, ip=None, type=None, ipType=None):
        """
        add nta ip config
        """
        uri = self._console_url + "/__api/nta/config/ip/" + str(type)
        data = {
            "desc": "%s" % ( desc ),
            "ipType": ipType,
            "ip": "%s" % ( ip )
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages']

    def delete_ip(self, id=None):
        """
        delete nta ip config
        """
        if id:
            uri = self._console_url + "/__api/nta/config/ip/" + str(id)
            print uri
            header = {'Content-Type': 'application/json'}
            response = self._session.delete(uri, headers=header)
            response_content = json.loads(response.content)
            status_code_check(response.status_code, 200)
            response_status_check(response_content['statusCode'], 0, response_content['messages'])
            return response_content['messages']

    def list_port(self, type=None):
        """
        query nta port
        """
        uri = self._console_url + "/__api/nta/config/port/" + str(type)
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #result = [(item.get('id')) for item in response_content['data']]

        return response_content['data'][0]['id']

    def add_port(self, desc=None, type=None, port=None):
        """
        add nta port
        """
        uri = self._console_url + "/__api/nta/config/port/" + str(type)
        data = {
            "desc": "%s" % ( desc ),
            "port": port
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages']

    def delete_port(self, id=None):
        """
        delete nta port
        """
        if id:
            uri = self._console_url + "/__api/nta/config/port/" + str(id)
            print uri
            header = {'Content-Type': 'application/json'}
            response = self._session.delete(uri, headers=header)
            response_content = json.loads(response.content)
            status_code_check(response.status_code, 200)
            response_status_check(response_content['statusCode'], 0, response_content['messages'])
            return response_content['messages']

    def add_postfix(self, desc=None, type=None, postfix=None):
        """
        add nta postfix
        """
        uri = self._console_url + "/__api/nta/config/postfix/" + str(type)
        data = {
            "desc": "%s" % ( desc ),
            "postfix": "%s" % ( postfix )
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['messages']

    def list_postfix(self, type=None):
        """
        query nta postfix
        """
        uri = self._console_url + "/__api/nta/config/postfix/" + str(type)

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #result = [(item.get('id')) for item in response_content['data']]
        return response_content['data'][0]['id']

    def delete_postfix(self, id=None):
        """
        delete nta postfix
        """
        if id:
            uri = self._console_url + "/__api/nta/config/postfix/" + str(id)
            print uri
            header = {'Content-Type': 'application/json'}
            response = self._session.delete(uri, headers=header)
            response_content = json.loads(response.content)
            status_code_check(response.status_code, 200)
            response_status_check(response_content['statusCode'], 0, response_content['messages'])
            return response_content['messages']

    def query_rsp_str(self, parameter_def=None, parameter=None):
        """
        Query nta logs count with parameter
        """
        uri = self._console_url + "/__api/discover/search"
        if parameter:
            parameter_def = parameter_def + ' AND ' + parameter
        data = {
            "source": "event",
            "timeFilter": "发生时间 >=now/w AND 发生时间 <now/w+1w",
            "filter": "%s" % ( parameter_def ),
            "search": {
                "from": 0,
                "size": 20,
                "columns": [
                    {
                        "field": "occur_time",
                        "order": "desc",
                        "highlight": True
                    },
                    {
                        "field": "end_time",
                        "highlight": True
                    },
                    {
                        "field": "src_address",
                        "highlight": True
                    },
                    {
                        "field": "src_port",
                        "highlight": True
                    },
                    {
                        "field": "dst_address",
                        "highlight": True
                    },
                    {
                        "field": "dst_port",
                        "highlight": True
                    },
                    {
                        "field": "domain_name",
                        "highlight": True
                    },
                    {
                        "field": "request_Method",
                        "highlight": True
                    },
                    {
                        "field": "url",
                        "highlight": True
                    },
                    {
                        "field": "status_code",
                        "highlight": True
                    },
                    {
                        "field": "send_byte",
                        "highlight": True
                    },
                    {
                        "field": "receive_byte",
                        "highlight": True
                    },
                    {
                        "field": "protocol",
                        "highlight": True
                    },
                    {
                        "field": "referer",
                        "highlight": True
                    },
                    {
                        "field": "request_path",
                        "highlight": True
                    },
                    {
                        "field": "pcapstore",
                        "highlight": True
                    },
                    {
                        "field": "request",
                        "highlight": True
                    },
                    {
                        "field": "rsp",
                        "highlight": True
                    },
                    {
                        "field": "sensor_id",
                        "highlight": True
                    }
                ]
            }
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        str_response_content = json.dumps(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return str_response_content

    def query_rsp_total(self, parameter_def=None, parameter=None):
        """
        Query nta logs count with parameter
        """
        uri = self._console_url + "/__api/discover/search"
        if parameter:
            parameter_def = parameter_def + ' AND ' + parameter
        data = {
            "source": "event",
            "timeFilter": "发生时间 >=now/w AND 发生时间 <now/w+1w",
            "filter": "%s" % ( parameter_def ),
            "search": {
                "from": 0,
                "size": 20,
                "columns": [
                    {
                        "field": "occur_time",
                        "order": "desc",
                        "highlight": True
                    },
                    {
                        "field": "end_time",
                        "highlight": True
                    },
                    {
                        "field": "src_address",
                        "highlight": True
                    },
                    {
                        "field": "src_port",
                        "highlight": True
                    },
                    {
                        "field": "dst_address",
                        "highlight": True
                    },
                    {
                        "field": "dst_port",
                        "highlight": True
                    },
                    {
                        "field": "domain_name",
                        "highlight": True
                    },
                    {
                        "field": "request_Method",
                        "highlight": True
                    },
                    {
                        "field": "url",
                        "highlight": True
                    },
                    {
                        "field": "status_code",
                        "highlight": True
                    },
                    {
                        "field": "send_byte",
                        "highlight": True
                    },
                    {
                        "field": "receive_byte",
                        "highlight": True
                    },
                    {
                        "field": "protocol",
                        "highlight": True
                    },
                    {
                        "field": "referer",
                        "highlight": True
                    },
                    {
                        "field": "request_path",
                        "highlight": True
                    },
                    {
                        "field": "pcapstore",
                        "highlight": True
                    },
                    {
                        "field": "request",
                        "highlight": True
                    },
                    {
                        "field": "rsp",
                        "highlight": True
                    },
                    {
                        "field": "sensor_id",
                        "highlight": True
                    }
                ]
            }
        }
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        print response_content
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['search']['total']