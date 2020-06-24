# -*- coding: utf-8 -*-

import json

from ._internal_utils import status_code_check, response_status_check, convert_date_time, EntityType, ShareType
from datetime import datetime, date, timedelta
import time
import logging
from .user import User

log = logging.getLogger(__name__)


class Dashboard(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self._entity_type = EntityType['dashboard']

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def list(self):
        """Get dashboard list

        :param start_time: start date, default is today
        :param end_time: end date, default is tomorrow
        :return: data
        """

        uri = self._console_url + '/__api/dashboard/boards'

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def get(self, id):
        """Get dashboard by id

        :param id: dashboard id
        :return: dashboard info dict
        """

        uri = self._console_url + '/__api/dashboard/boards/' + id

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def get_by_name(self, name):
        """Get dashboard by name

        :param name: dashboard name
        :return: dashboard info dict
        """

        dashboard_list = self.list()
        return [dashboard for dashboard in dashboard_list['list'] if dashboard['name'] == name][0]

    def create_by_data(self, data):
        """Create dashboard

        :param data: dashboard data
        :return: dashboard id
        """

        uri = self._console_url + '/__api/dashboard/boards'
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['id']

    def create(self, name=None, data=None, **kwargs):
        """Create dashboard

        :param name: dashboard name, required
        :param editable: dashboard editable or not, default is true
        :param layout_mode: dashboard layout mode, default is gridster
        :param layout_params: dashboard layout params
        :param data: dashboard data
        :param kwargs: other optional args
        :return: dashboard id
        """

        if data:
            create_data = data
        else:
            assert name
            create_data = {
                'name': name,
                'openAt': int(time.time())*1000,
                'readonly': kwargs.pop('readonly', False),
                'refresh': "{'interval':-1,'paused':false}",
                'time': {
                    'type': "quick",
                    'value': ">=now/d,<now/d+1d"
                }
            }
        return self.create_by_data(create_data)

    def get_charts(self, id):
        """Get component list on this dashboard

        :param id: dashboard id
        :return: component list
        """
        uri = self._console_url + '/__api/dashboard/boards/' + id + '/charts'
        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def add_chart(self, id, chart_id, **kwargs):
        """Add component to this dashboard, only add on component once, if want to add n-times, call n-times

        :param id: dashboard id
        :param component_id: component id, string format
        :return: None
        """
        position = {
            'height': kwargs.pop("height", 6),
            'left': kwargs.pop("left", 5),
            'top': kwargs.pop("top", 0),
            'width': kwargs.pop("width", 6)
        }

        payload = {
            'create': {
                'id': chart_id,
                'position': position,
                'type':"chart"
            },
            'update': []
        }

        uri = self._console_url + '/__api/dashboard/boards/' + id + '/chart/cud'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def update_chart(self, id, chart_id, **kwargs):
        """Update component on this dashboard

        :param id: dashboard id
        :param component_id: component id
        :param data: update args
        :param kwargs: other optional keywords
        :return: None
        """
        uri = self._console_url + '/__api/dashboard/boards/' + id + '/chart/cud'
        position = {
            'height': kwargs.pop("height", 13),
            'left': kwargs.pop("left", 6),
            'top': kwargs.pop("top", 0),
            'width': kwargs.pop("width", 18)
        }

        payload = {
            'update': [
                {
                    'id': chart_id,
                    'type': "chart",
                    'position': position
                }
            ]
        }

        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_chart(self, id, chart_id):
        """Delete component on this dashboard

        :param id: dashboard id
        :param component_id: component id, string format
        :param height: component height
        :param width: component width
        :return: None
        """
        uri = self._console_url + '/__api/dashboard/boards/' + id + '/chart/cud'
        payload = {
            'remove': {
                'type': 'chart',
                'id': chart_id
            },
            'update': []
        }

        response = self._session.post(uri, payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])


    def update(self, id, data=None, **kwargs):
        """Update dashboard

        :param id: dashboard id
        :param data: dashboard data
        :param kwargs: optional arguments to update dashboard
        :return: None
        """

        uri = self._console_url + '/__api/dashboard/boards/' + id
        if data:
            update_data = data
        else:
            update_data = self.get(id)
            name = kwargs.pop('name', None)
            if name:
                update_data['name'] = name
            update_data['openAt'] = int(time.time()) * 1000

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def delete(self, id):
        """Delete dashboard by id, dashboard cannot be deleted if it has component

        :param id: dashboard id
        :return: None
        """
        uri = self._console_url + '/__api/dashboard/boards/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, json=header)
        status_code_check(response.status_code, 200)

    def delete_all(self):
        """Delete all assets

        :return: None
        """

        dashboard_list = self.list()
        for dashboard in dashboard_list['list']:
            try:
                self.delete(dashboard['id'])
            except Exception as ex:
                print ex
                
    def get_share_info(self, id):
        """Get share type for dashboard

        :param id: dashboard id
        :return: shareType
        """

        uri = self._console_url + '/__api/dashboard/' + id + '/share'

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']

    def update_share_info(self, id, **kwargs):
        """Set share type for dashboard

        :param id: dashboard id
        :param share_type: share type
        :param users: users if set shareType=2
        :return: None

        不分享：shareType=self_0
        公开：shareType=open_1
        指定用户：shareType=specific_2
        """

        uri = self._console_url + '/__api/dashboard/' + id + '/share'
        share_type = kwargs.pop("shareType", None)
        users = kwargs.pop("users", None)
        _share_type = ShareType.get(share_type, 1)

        _user = User(self._console_url, self._session)

        payload = {
            'shareType': _share_type,
            'cascade': True
        }
        if share_type == 'specific':
            assert users
            user_list = [_user.get_by_name(i)['id'] for i in users]
            payload['users'] = user_list

        response = self._session.put(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def drilldown_config(self, board_name, chart_name, dst_name, type):
        board = self.get_by_name(board_name)
        board_id = board['id']
        charts = self.get_charts(board_id)
        chart_id = [chart['id'] for chart in charts['list'] if chart.get('name') == chart_name][0]

        uri = self._console_url + '/__api/dashboard/boards/' + board_id + '/charts/' + chart_id + '/drilldown'

        if type == "dashboard":
            board_data = self.get_by_name(dst_name)
            param = board_data['id']
        if type == "url":
            url_data = {
                u"安全事件列表": "/cases/incident?filterName=${name}&filterValue=${value}",
                u"安全事件详情": "/cases/incident?id=${value}&ictFrom=4",
                u"资产域风险": "/asset/risk?domain=${key}&node=${value}",
                u"资产详情": "/asset/ip_detail?ip=${value}",
                u"脆弱性列表": "/cases/vulnerability?filterName=${name}&filterValue=${value}",
                u"脆弱性详情": "/cases/vulnerability?id=${value}&ictFrom=3",
                u"异常用户分析列表页": "/ueba/users?type=list&key=${key}&value=${value}",
                u"异常用户详情页": "/ueba/users?type=detail&value=${value}",
                u"重点关注用户列表页": "/ueba/watching_users?type=list&key=${key}&value=${value}",
            }
            param = url_data[dst_name]

        payload = {
            'fields': None,
            'name': dst_name,
            'param': param,
            'target': type
        }

        response = self._session.put(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

