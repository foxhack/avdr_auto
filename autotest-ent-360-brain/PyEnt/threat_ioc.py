# -*- coding:utf-8 -*-

import json
from ._internal_utils import status_code_check, response_status_check

class ThreatIoc(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def ioc_tags(self, ioc_list):
        '''
        Get the ioc tags.
        :param ioc_list: ioc list
        :return: ioc and tags
        '''
        uri = self._console_url + '/__api/system/tip/tag'
        payload = {"ips": ioc_list}
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def display_threat_summary(self, ioc):
        '''
        Drill down ioc detail page. including risk score, threat_severity, threat_level, geo info, history info, asn, tags( tag_details and tags)
        :param ioc:
        :return:
        '''
        uri = self._console_url + '/__api/ti/list'
        payload = {
            "ioc": ioc,
            "locale": "zh_cn"
        }
        response = self._session.get(uri, params=payload, verify=False)
        print response.url
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #print response_content['data']
        return response_content['data']

    def alerttype_id_details(self, ioc):
        '''
        In Theatintelligence detail page, getting the alert type.
        :return:
        '''
        uri = self._console_url + '/__api/ice/api/incident/alert_type'
        payload = {
            "filter": "internet=" + "'" + str(ioc) + "'",
            "source": "incident_merge",
            "timeFilter": "发生时间 >=now-30d AND 发生时间 <=now"
        }
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        print response_content['data']
        return response_content['data']

    def get_alerttype_by_id(self, id):
        '''
        Get the alert type name by id.
        :param id: id
        :return:
        '''
        uri = self._console_url + '/__api/sae/api/cep/rule-types/' + str(id)
        response = self._session.get(uri, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['name']

    def get_related_intranrtip(self, ioc):
        '''
        Get related intranet ip.
        :param ioc: ioc
        :return: intranet ip list
        '''
        uri = self._console_url + '/__api/ice/api/incident/victim'
        payload = {
            "filter": "internet=" + "'" + str(ioc) + "'",
            "source": "incident",
            "timeFilter": "发生时间 >=now-30d AND 发生时间 <=now"
        }
        response = self._session.post(uri, json=payload, headers={"Content-Type": "application/json"}, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_ice_related_to_ioc(self, ioc):
        '''
        Get the incident info related to ioc.
        :param ioc:
        :return:
        '''
        uri = self._console_url + '/__api/ice/api/incident/ioc?locale=en'
        filter = "internet=" + "'" + str(ioc) + "'"
        payload = {
            "source": "incident",
            "search": {"from": "0", "size": "20"},
            "timeFilter": "发生时间 >=now-30d AND 发生时间 <=now",
            "filter": filter
        }
        #print filter
        response = self._session.post(uri, json=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        #response_status_check(response_content['messages'], 0, response_content['messages'])
        return response_content['data']

    def get_portinfo_details(self, ioc):
        '''
        Get the port info details related to ioc.
        :param ioc:
        :return:
        '''
        uri = self._console_url + '/__api/ti/portInfo'
        payload = {
            "ioc": ioc,
            "locale": "en"
        }
        response = self._session.get(uri, params=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content['data']

    def get_relatedinfo_details(self, ioc):
        '''
        Get the related info of ioc.
        :param ioc:
        :return:
        '''
        uri = self._console_url + '/__api/ti/relatedInfo'
        payload = {
            "ioc": ioc,
            "locale": "en"
        }
        response = self._session.get(uri, params=payload, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        return response_content['data']

    def ti_query_event(self, lic_file, ioc):
        '''
        Online event query.
        :return: Threat Info from TI Server.
        '''
        content = open(lic_file, 'rb').read()
        uri = 'https://ti.hansight.com/v1/query/event'
        payload = {
            "auth": {
                "auth": "license",
                "type": "file",
                "content": content,
                "version": "5.0",
                "buildnum": "5941"
            },
            "data": [{'v': ioc, 't': 0, 'c': 1}]
        }
        response = self._session.post(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)
        #print response.content
        if response.content:
            response_content = json.loads(response.content)
            print response_content
            return response_content
        else:
            print 'No response data!'



    def ti_query_alarm(self, lic_file, ioc):
        '''
        Online event query.
        :return: Threat Info from TI Server.
        '''
        content = open(lic_file, 'rb+').read()
        uri = 'https://ti.hansight.com/v1/query/alarm'
        payload = {
            "auth": {
                "auth": "license",
                "type": "file",
                "content": content,
                "version": "5.0",
                "buildnum": "28346167"
            },
            "data": [{
                'ip': ioc,
                'alarms': [dict(alarmName='test1', domains=[], type=0, count=0)]
            }]
        }
        #print payload
        response = self._session.post(uri, json=payload, verify=False)
        status_code_check(response.status_code, 200)
        if response.content:
            response_content = json.loads(response.content)
            print response_content
            return response_content
        else:
            print 'No response data!'

    def ti_query_online(self, ioc, type='ip'):
        '''
        Query ioc online, url: https://ti.hansight.com
        :param ioc: ioc
        :param type: ip, domain, url, hash, email and so on.
        :return: data list
        '''
        uri = 'https://ti.hansight.com/ui/search'
        payload = {
            "ioc": str(ioc),
            "queryType": "detail",
            "type": type
        }
        print uri
        response = self._session.get(uri, data=payload, headers={"Content-Type": "application/json;charset=UTF-8"}, verify=False)
        print response.url
        if response.content:
            response_content = json.loads(response.content)
            #print response_content['data']['Ti']['ioc']
            print response_content
            return response_content