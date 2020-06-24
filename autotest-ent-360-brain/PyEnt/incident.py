# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check, convert_date_time

from datetime import datetime, date, timedelta
import logging
from connection import MySql
import urlparse
import time

log = logging.getLogger(__name__)


class Incident(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self.header = {'Content-Type': 'application/json'}
        self._host = urlparse.urlparse(console_url).hostname
        self._node_chain = MySql(self._host).execute_sql_cmd("SELECT id FROM system_node")
        self._end_time = int(time.time() * 1000)
        self._start_time = self._end_time - 3600*24*1000*7

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get_current_node_chain(self):
        return self._node_chain

    def get_incident_list(self, condition=None):
        uri = self._console_url + '/__api/ice/api/incidents/search'
        data = {
            "source": "incident",
            "timeFilter": "开始时间 >=now-30d AND 开始时间 <=now",
            "filter": "%s" % (condition if condition else ""),
            "search": {
                "from": 0,
                "size": 10
            },
            "sort": {
                "field": "priority",
                "order": "desc"
            }
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]["list"]

    def update_incident(self, id, **kwargs):
        uri = self._console_url + '/__api/ice/api/incidents/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)
        data = {
            "id": "%s" % id,
            "priority": 83,
            "severity": 2,
            "attack_phase": [5],
            "type": 10011,
            "title": "default",
            "advice": "-"
        }

        incident = self.get_incident_info(id)

        for key in data:
            data[key] = incident[key]

        for i in kwargs:
            if i in data:
                data[i] = kwargs[i]

        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_incident(self, id):
        uri = self._console_url + '/__api/ice/api/incidents/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)

        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def add_incident_to_case(self, name):
        uri = self._console_url + '/__api/security/attack'
        data = {
            "name": name,
            "attackName": "案例分类",
            "typeId": "16AWKYFY9000f",
            "description": name,
            "tags": [],
            "relationLink": ""
        }

        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def get_incident_detail_timeline(self, id):
        uri = self._console_url + '/__api/ice/api/incident/detail?nodeChain=%s&ictFrom=4' % self._node_chain
        data = {
            "source": "incident_merge",
            "timeFilter": "start_time>=%s AND start_time<=%s" % (self._start_time, self._end_time),
            "filter": "incident_id = %s" % id,
            "search": {
                "from": 0,
                "size": 30
            },
            "sort": {
                "field": "start_time",
                "order": "desc"
            }
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]["list"]

    def change_incident_owner(self, id, user_id):
        uri = self._console_url + '/__api/ice/api/incident/owner?nodeChain=%s&ictFrom=4' % self._node_chain
        data = {
            "incidentId": id,
            "ictFrom": 4,
            "post": user_id,
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def change_incident_handle_status(self, id, status):
        uri = self._console_url + '/__api/ice/api/incident/disposal?nodeChain=%s&ictFrom=4' % self._node_chain
        data = {
            "incidentId": id,
            "pre": 1,
            "post": int(status),
            "comments": ''
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def change_incident_ack_status(self, id, status):
        uri = self._console_url + '/__api/ice/api/incident/acknowledge?nodeChain=%s&ictFrom=4' % self._node_chain
        data = {
            "incidentId": id,
            "pre": 0,
            "post": int(status),
            "comments": '',
            "mergeAlertList": []
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def get_incident_audit_history(self, id):
        uri = self._console_url + '/__api/ice/api/incident/disposal/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_incident_advice(self, id):
        uri = self._console_url + '/__api/ice/api/incident/advice/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_incident_latest_event_alert(self, id):
        uri = self._console_url + '/__api/ice/api/incident/news/%s?nodeChain=%s&startTime=%s&endTime=%s' % (id, self._node_chain, self._start_time, self._end_time)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_incident_ip_relation_info(self, id):
        uri = self._console_url + '/__api/ice/api/incidents/ip-relation/%s?nodeChain=%s&top=false' % (id, self._node_chain)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_incident_merge_tendency(self, id, dtype):
        """
        dtype: day or hour
        """
        uri = self._console_url + '/__api/ice/api/incident/merge/tendency/%s?nodeChain=%s&startTime=%s&endTime=%s&type=%s' % (id, self._node_chain, self._start_time, self._end_time, dtype)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        total_count = 0
        for i in response_content["data"]:
            total_count = total_count + int(i['docCount'])

        return total_count

    def get_incident_graph(self, id):
        uri = self._console_url + '/__api/ice/api/incident/graph/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)
        
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_incident_sankey_diagram(self, id):
        uri = self._console_url + '/__api/ice/api/incident/sankey_diagram/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)
        
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def delete_merge_alert(self, id):
        uri = self._console_url + '/__api/ice/api/incident/merge/%s?source_type=0' % id
        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def get_incident_info(self, id):
        uri = self._console_url + '/__api/ice/api/incidents/%s?nodeChain=%s&ictFrom=4' % (id, self._node_chain)

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def creat_incident(self, dtype):
        """
        dtype: 0-原始日志; 1-原始告警
        """
        uri = self._console_url + '/__api/ice/api/incidents'
        data = {
            "type": dtype
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def add_event_alarm_to_incident(self, dtype, id):
        """
        dtype: 0-原始日志; 1-原始告警
        id: incident id
        """
        uri = self._console_url + '/__api/ice/api/incident/manual'
        data = {
            "type": dtype,
            "id": id
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def list_incident_rules(self):
        uri = self._console_url + '/__api/ice/api/incident/rules?page=1&page_size=100'

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]['list']

    def list_incident_rule_types(self):
        uri = self._console_url + '/__api/ice/api/incident/types'

        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def start_incident_rule(self, rule_id):
        uri = self._console_url + '/__api/ice/api/incident/rules/operate/%s' % rule_id
        data = {"operate": 1}

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def stop_incident_rule(self, rule_id):
        uri = self._console_url + '/__api/ice/api/incident/rules/operate/%s' % rule_id
        data = {"operate": 0}

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_incident_rule(self, rule_id):
        uri = self._console_url + '/__api/ice/api/incident/rules/%s' % rule_id

        response = self._session.delete(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def create_ice_task(self, name, relativeIds, relativeRules=['1']):
        uri = self._console_url + '/__api/ice/api/incident/tasks'
        data = {
            "name": name,
            "description": "aaa",
            "relativeRules": relativeRules,
            "relativeIds": {
                "id": 'start_time'
            },
            "relativeType": 0
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def list_ice_tasks(self):
        uri = self._console_url + '/__api/ice/api/incident/tasks'
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]['list']

    def get_all_attcks(self):
        uri = self._console_url + '/__api/attck/matrix'
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_mapping_attcks(self):
        uri = self._console_url + '/__api/ice/api/incidents/attck/search'
        data = {
            "source": "incident",
            "filter": "ATTCK_Mapping exist",
            "timeFilter": "start_time >=now/w AND start_time<now/w+1w"
        }

        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def get_technique_info(self, tech_id):
        uri = self._console_url + '/__api/attck/techniques/%s' % tech_id
        response = self._session.get(uri, headers=self.header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content["data"]

    def get_icerule(self, id):
        uri = self._console_url + '/__api/ice/api/incident/rules/' + str(id)
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_icerule_by_name(self, name):
        ice_rule_list = self.list_incident_rules()
        return [rule for rule in ice_rule_list if rule["name"] == name][0]

    def update_incident_rule_notification(self, id, notifier=None, notification=None):
        uri = self._console_url + '/__api/ice/api/incident/rules/' + str(id)
        update_data = self.get_icerule(id)
        if notifier:
            update_data['notifier'] = notifier
        if notification:
            update_data['notification'] = notification
        if update_data['sysId'] == "":
            print update_data['sysId']
            update_data['sysId'] = None
            print update_data['sysId']

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
