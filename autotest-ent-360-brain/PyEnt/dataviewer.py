# -*- coding: utf-8 -*-

import json
import codecs
import re
import time
from .assettype import AssetType
from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)


class DVCollector(object):
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
        """Get all collectors

        :return: collector list
        """
        uri = self._console_url + "/__api/dv/collector"
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        #response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content

    def get_by_id(self, id):
        """Get collector by id

        :param id: collector id
        :return: collector info dict
        """
        collector_list = self.list()
        return [collector for collector in collector_list if collector['id'] == id][0]

    def get_worker_status(self, id):
        """Get worker status 
        
        :param id: worker id
        :return: worker status, RUNNING if work normally
        """
        collector_list = self.list()
        return [collector for collector in collector_list if collector['id'] == id][0]['status']


class DVParser(object):
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
        """Get all parsers in dv
        
        :return: parser list
        """
        uri = self._console_url + '/__api/dv/resolver'
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content

    def get(self, id):
        """Get parser by id
        
        :param id: parser id
        :return: parser info dict
        """
        uri = self._console_url + '/__api/dv/resolver/' + id
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content

    def get_by_name(self, name):
        """Get parser by name
        
        :param name: parser name
        :return: parser info dict
        """
        parsers = self.list()
        return [parser for parser in parsers if parser['name'] == name][0]

    def preview(self, data):
        """Preview for dv, get properties attr
        
        :param data: parser and normalize info dict for a parser
        :return: properties attr
        """
        uri = self._console_url + '/__api/dv/previewer'
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.post(uri, json=data)
        status_code_check(response.status_code, 200)
        response_content = json.loads(response.content)
        return response_content

    def create_by_data(self, data):
        """Create parser by data
        
        :param data: parser data, need to get preview info first
        :asset_type: asset type
        :return: parser id and name tuple
        """
        uri = self._console_url + '/__api/dv/resolver'
        header = {'Content-Encoding': 'UTF-8'}
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['status'], 200, response_content['message'])
        # u'保存成功，解析规则[名称=test3]'
        ptn = re.compile(u'保存成功，解析规则\[名称=(.+)\]')
        res = ptn.search(response_content['message'])
        if res:
            return res.groups()
        else:
            raise Exception('save parser failed')

    def create(self, data, asset_type_name='Linux'):
        """Create parser by data
        
        :param data: parser info data
        :return: parser id and name tuple
        """
        _asset_type = AssetType(self._console_url, self._session)
        asset_type = _asset_type.get_by_name(asset_type_name)
        data['assetType'] = {
            "name": asset_type_name,
            "id": asset_type['id'],
        }
        preview = dict()
        preview['parser'] = [[data["sample"], ], data["parser"]]
        preview['normalize'] = data["normalize"]
        properties = self.preview(preview)
        data['properties'] = properties
        return self.create_by_data(data)

    def create_by_file(self, local_file, name=None):
        """Create parser by file
        
        :param local_file: parser file
        :param name: parser name
        :return: parser id and name tuple
        """
        with codecs.open(local_file, 'r', 'utf-8') as pf:
            content = pf.read().strip()
        parser_dict = json.loads(content)
        if name:
            parser_dict['name'] = name
        return self.create_by_data(parser_dict)

    def import_parser_rule_file(self, local_file):
        """Import the exported parser rule file
        
        :local_file: the path of local parser rule file
        :return: None
        """
        uri = self._console_url + '/__api/dv/resolver/upload'
        header = {'Content-Encoding': 'UTF-8'}
        files = {'file':('default', open(local_file, 'rb'), 'application/octet-stream')}

        response = self._session.post(uri, files=files)

    def export_parser_rule_file(self, local_file, rule_name=None):
        """Export dv parser rule to local

        :local_file: the path of exported parser rule file
        :rule_name: the specified dv parser rule name list, if empty, then export all
        :return: None
        """
        uri = self._console_url + '/__api/dv/resolver/download'
        header = {'Content-Type': 'application/json'}
        rule_ids = []

        if rule_name:
            for i in rule_name:
                rule = self.get_by_name(i)
                rule_ids.append(rule["id"])

        if rule_ids:
            response = self._session.post(uri, data=json.dumps(rule_ids), headers=header)
        else:
            response = self._session.post(uri)

        response_content = json.loads(response.content)

        with open(local_file, 'wb') as pf:
            pf.write(response_content["data"])

    def delete(self, id):
        """Delete parser by id
        
        :param id: parser id
        :return: None
        """
        uri = self._console_url + '/__api/dv/resolver/' + id
        header = {'Content-Type': 'application/json'}

        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], '0', response_content['messages'])

    def delete_by_name(self, name):
        """Delete parser by name
        
        :param name: parser name
        :return: None
        """
        parser_id = self.get_by_name(name)['id']
        self.delete(parser_id)

    def delete_all(self):
        """Delete all parsers

        :return: None
        """

        for parser in self.list():
            try:
                self.delete(parser['id'])
            except Exception as ex:
                pass

    def update(self, id, data=None, **kwargs):
        """Update parser

        :param id: parser id
        :param data: update data
        :param kwargs: optional data
        :return: 
        """
        uri = self._console_url + '/__api/dv/resolver'
        header = {'Content-Encoding': 'UTF-8'}
        if data:
            update_data = data
        else:
            update_data = self.get(id)
            name = kwargs.pop('name', None)
            if name:
                update_data['name'] = name
                # other kwargs handler

        response = self._session.post(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])


class DVSource(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self._dv_source_id = None

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def list(self):
        """Get all datasources in dv
        
        :return: datasource list
        """
        uri = self._console_url + '/__api/dv/datasource'
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content

    def get(self, id):
        """Get datasource info by id
        
        :param id: datasource id
        :return: datasource info dict
        """
        uri = self._console_url + '/__api/dv/datasource/' + id
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content

    def get_by_name(self, name):
        """Get datasource info by name
        
        :param name: datasource name
        :return: None
        """
        parsers = self.list()
        return [parser for parser in parsers if parser['name'] == name][0]

    def create(self, name="test_syslog", collector="worker-001", resolver=["netflow"], source_ip="127.0.0.1", **kwargs):
        """Create datasource
        
        :param name: datasource name
        :param collector: the worker id
        :param resolver: parser rule name
        :param kwargs: optional info
        :return: None
        """
        parser_id = []
        _parser = DVParser(self._console_url, self._session)

        for i in resolver:
            parser = _parser.get_by_name(i)
            parser_id.append(parser["id"])

        data = {
            "_writers": {
                "es": "Enterprise-ES",
                "kafka": "Enterprise-KAFKA"
            },
            "collectorId": collector,
            "data": {
                "contentType": "net",
                "protocol": "udp",
                "deviceIp": source_ip,
                "host": "0.0.0.0",
                "port": 514,
                "codec": {
                    "name": "none"
                },
                "properties": {
                    "encoding": "UTF-8"
                },
                "name": "net",
                "_version": "default",
                "positionList": [
                    {}
                ]
            },
            "name": name,
            "timerId": "",
            "assetId": "",
            "properties": {
                "polling_ms": "1000",
                "timeout_ms": "100"
            },
            "status": "STOPPED",
            "resolverIdList": parser_id,
            "writers": [
                {
                    "id": "es",
                    "name": "Enterprise-ES"
                },
                {
                    "id": "kafka",
                    "name": "Enterprise-KAFKA"
                },
                {
                    "id": "kafka-sae",
                    "name": "Enterprise-SAE-KAFKA"
                }
            ]
        }
        return self.create_by_data(data)

    def create_kafka_type(self, name="test_kafka", collector="worker-001", resolver=["netflow"], source_ip="127.0.0.1:9092", topic="test", **kwargs):
        """Create datasource
        
        :param name: datasource name
        :param collector: the worker id
        :param resolver: parser rule name
        :param kwargs: optional info
        :return: None
        """
        parser_id = []
        _parser = DVParser(self._console_url, self._session)

        for i in resolver:
            parser = _parser.get_by_name(i)
            parser_id.append(parser["id"])
            
        data = {
            "collectorId": "worker-001",
            "data": {
                "codec": {
                    "name": "none"
                },
                "properties": {
                    "encoding": "UTF-8"
                },
                "positionList": [
                    {}
                ],
                "name": "kafka",
                "hostPorts": source_ip,
                "_version": "0.10.1.0",
                "positionGoOn": "END",
                "wildcard": "false",
                "topic": topic,
                "authentication": "NONE"
            },
            "name": name,
            "resolverIdList": parser_id,
            "writers": [
                {
                    "id": "es",
                    "name": "Enterprise-ES"
                },
                {
                    "id": "kafka",
                    "name": "Enterprise-KAFKA"
                },
                {
                    "id": "kafka-sae",
                    "name": "Enterprise-SAE-KAFKA"
                }
            ]
        }
        return self.create_by_data(data)

    def create_file_type(self, name="test_file", collector="worker-001", resolver=["netflow"], file_path="/opt/test.txt", **kwargs):
        """Create datasource
        
        :param name: datasource name
        :param collector: the worker id
        :param resolver: parser rule name
        :param kwargs: optional info
        :return: None
        """
        parser_id = []
        _parser = DVParser(self._console_url, self._session)

        for i in resolver:
            parser = _parser.get_by_name(i)
            parser_id.append(parser["id"])
            
        data = {
            "collectorId": "worker-001",
            "data": {
                "codec": {
                    "name": "line"
                },
                "properties": {
                },
                "positionList": [
                    {}
                ],
                "name": "directory",
                "path": file_path,
                "contentType": "txt",
                "encoding": "UTF-8",
                "mask": "r",
                "positionGoOn": "END"
            },
            "name": name,
            "resolverIdList": parser_id,
            "writers": [
                {
                    "id": "es",
                    "name": "Enterprise-ES"
                },
                {
                    "id": "kafka",
                    "name": "Enterprise-KAFKA"
                },
                {
                    "id": "kafka-sae",
                    "name": "Enterprise-SAE-KAFKA"
                }
            ]
        }
        return self.create_by_data(data)

    def create_db_type(self, name="test_self_db", collector="worker-001", resolver=["netflow"], **kwargs):
        """Create datasource
        
        :param name: datasource name
        :param collector: the worker id
        :param resolver: parser rule name
        :param kwargs: optional info
        :return: None
        """
        parser_id = []
        _parser = DVParser(self._console_url, self._session)

        for i in resolver:
            parser = _parser.get_by_name(i)
            parser_id.append(parser["id"])
            
        data = {
            "collectorId": "worker-001",
            "data": {
                "codec": {
                },
                "properties": {
                    "user": "hansight",
                    "password": "HanS!gh5#NT",
                    "indextype": "digital"
                },
                "positionList": [
                    {
                        "position": 0
                    }
                ],
                "name": "jdbc",
                "protocol": "mysql",
                "schema": "hansight",
                "host": "127.0.0.1",
                "port": 3399,
                "tableOrSql": "system_unit",
                "column": "id",
                "step": 1,
                "positionGoOn": "END"
            },
            "name": name,
            "resolverIdList": parser_id,
            "writers": [
                {
                    "id": "es",
                    "name": "Enterprise-ES"
                },
                {
                    "id": "kafka",
                    "name": "Enterprise-KAFKA"
                },
                {
                    "id": "kafka-sae",
                    "name": "Enterprise-SAE-KAFKA"
                }
            ]
        }
        return self.create_by_data(data)

    def create_sftp_type(self, name="test_self_sftp", filepath="/opt/1.txt", resolver=["netflow"], host="127.0.0.1", username="root", pwd="hansight", **kwargs):
        """
        Create SFTP DV type
        """
        parser_id = []
        _parser = DVParser(self._console_url, self._session)

        for i in resolver:
            parser = _parser.get_by_name(i)
            parser_id.append(parser["id"])

        data = {
            "data": {
                "codec": {
                    "name": "line"
                },
                "properties": {
                    "user": username,
                    "password": pwd
                },
                "positionList": [
                    {
                        "position": 0
                    }
                ],
                "name": "sftp",
                "host": host,
                "port": "22",
                "contentType": "txt",
                "encoding": "UTF-8",
                "path": filepath,
                "skipLine": 0,
                "_version": "default",
                "positionGoOn": "END"
            },
            "resolverIdList": parser_id,
            "writers": [
                {
                    "id": "es",
                    "name": "Enterprise-ES"
                },
                {
                    "id": "kafka",
                    "name": "Enterprise-KAFKA"
                },
                {
                    "id": "kafka-sae",
                    "name": "Enterprise-SAE-KAFKA"
                }
            ],
            "properties": {
                "polling_ms": "1000",
                "timeout_ms": "100"
            },
            "name": name,
            "collectorId": "worker-001"
        }

        return self.create_by_data(data)


    def create_by_data(self, data):
        """Create datasource by data
        
        :param data: datasource info data
        :return: None
        """
        uri = self._console_url + '/__api/dv/datasource'
        header = {'Content-Encoding': 'UTF-8'}
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        self._dv_source_id = response_content['data']

    def create_by_file(self, local_file, collector, resolver, name=None):
        """Create datasource by file
        
        :param local_file: local file
        :param collector: collector id
        :param resolver: parser name
        :param name: datasource name
        :return: None
        """
        with codecs.open(local_file, 'r', 'utf-8') as pf:
            content = pf.read().strip()
        parser_dict = json.loads(content)
        parser_dict['collectorId'] = collector
        _parser = DVParser(self._console_url, self._session)
        # need to use assetType id and name
        _parser_info = _parser.get_by_name(resolver)
        parser_dict['resolverId'] = _parser_info["id"]
        parser_dict['assetTypeId'] = _parser_info["assetType"]["id"]
        parser_dict['assetTypeName'] = _parser_info["assetType"]["name"]
        parser_dict['assetType'] = {
                "name": _parser_info["assetType"]["name"],
                "id": _parser_info["assetType"]["id"],
            }
        if name:
            parser_dict['name'] = name
        return self.create_by_data(parser_dict)

    def start(self, id):
        """Start datasource by id
        
        :param id: datasource id
        :return: None
        """
        status = self.get(id)['status']
        if status == "RUNNING":
            print id, " is running, need not to start"
            return
        payload = {
            'opt': 'start',
            'id': id,
        }
        uri = self._console_url + '/__api/dv/config/start/' + id
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.put(uri, json=payload)
        time.sleep(10)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], '0', response_content['messages'])

    def start_by_name(self, name):
        """Start datasource by name
        
        :param name: datasource name
        :return: None
        """
        s = self.get_by_name(name)
        self.start(s['id'])

    def stop(self, id):
        """Stop datasource by id
        
        :param id: datasource id
        :return: None
        """
        status = self.get(id)['status']
        if status == "STOPPED":
            print id, " is stopped, need not to stop"
            return
        payload = {
            'opt': 'stop',
            'id': id,
        }
        uri = self._console_url + '/__api/dv/config/stop/' + id
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.put(uri, json=payload)
        time.sleep(10)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], '0', response_content['messages'])

    def stop_by_name(self, name):
        """Stop datasource by name
        
        :param name: datasource name
        :return: None
        """
        s = self.get_by_name(name)
        self.stop(s['id'])

    def delete(self, id):
        """Delete datasource by id
        
        :param id: datasource id
        :return: None
        """
        uri = self._console_url + '/__api/dv/datasource/' + id
        header = {'Content-Type': 'application/json'}

        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_by_name(self, name):
        """Delete datasource by name
        
        :param name: datasource name
        :return: None
        """
        source_id = self.get_by_name(name)['id']
        self.delete(source_id)

    def delete_all(self):
        """Delete all datasources

        :return: None
        """

        for ds in self.list():
            try:
                self.delete(ds['id'])
            except Exception as ex:
                pass

    def stop_delete_all(self):
        """Stop and delete all datasources
        
        :return: None
        """
        import time
        for ds in self.list():
            try:
                self.stop(ds['id'])
                time.sleep(5)
                self.delete(ds['id'])
                time.sleep(5)
            except Exception as ex:
                pass

    def update(self, id, data=None, **kwargs):
        """Update datasource
        
        :param id: datasource id
        :param data: update data
        :param kwargs: optional data
        :return: 
        """
        uri = self._console_url + '/__api/dv/datasource'
        header = {'Content-Encoding': 'UTF-8'}
        if data:
            update_data = data
        else:
            update_data = self.get(id)
            name = kwargs.pop('name', None)
            if name:
                update_data['name'] = name
                # other kwargs handler

        response = self._session.post(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['status'], '200', response_content['message'])

class DVStore(object):
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
        """Get all dv store
        
        :return: store list
        """
        uri = self._console_url + '/__api/dv/writer'
        header = {'Content-Encoding': 'UTF-8'}

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content

    def delete(self, id):
        """Delete dv store by id
        
        :param id: dv store id
        :return: None
        """
        uri = self._console_url + '/__api/dv/writer/' + id
        header = {'Content-Type': 'application/json'}

        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], '0', response_content['messages'])

    def get_by_name(self, name):
        """Get dv store info by name
        
        :param name: dv store name
        :return: None
        """
        stores = self.list()
        return [i for i in stores if i['name'] == name][0]

    def create(self, store_type=None, name=None, address=None):
        """
        """
        uri = self._console_url + '/__api/dv/writer'
        header = {'Content-Encoding': 'UTF-8'}
        data = {}

        if store_type == 'es':
            data = {
                "data": {
                    "cache": 1000,
                    "cluster": "hansight-enterprise",
                    "date_detection": False,
                    "hostPorts": [
                        [
                            address,
                            9300
                        ]
                    ],
                    "index": "event_$",
                    "indexType": "event",
                    "name": "es",
                    "number_of_replicas": 0,
                    "number_of_shards": 5,
                    "persisRef": {
                        "field": "occur_time",
                        "format": "yyyyMMdd",
                        "name": "date"
                    },
                    "tmpHostPorts": "%s:9300" % address
                },
                "name": name
            }

        elif store_type == 'kafka':
            data = {
                "data": {
                    "_version": "0.10.1.0",
                    "authentication": "NONE",
                    "cache": 1000,
                    "contentType": {
                        "encoding": "utf-8",
                        "name": "json"
                    },
                    "hostPorts": "%s:9092" % address,
                    "name": "kafka",
                    "persisRef": {
                        "name": "none"
                    },
                    "topic": "event"
                },
                "name": name
            }
        
        elif store_type == 'net':
            data = {
                "data": {
                    "cache": 1000,
                    "contentType": {
                        "encoding": "utf-8",
                        "name": "json"
                    },
                    "host": address,
                    "name": "net",
                    "persisRef": {
                        "name": "none"
                    },
                    "port": 222,
                    "protocol": "udp"
                },
                "name": name
            }
        
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], '0', response_content['messages'])
