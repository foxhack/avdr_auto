# -*- coding: utf-8 -*-

import json

from .discovercharts import DiscoverCharts
from .discovermeta import DiscoverMeta
from ._internal_utils import status_code_check, response_status_check, convert_date_time

from datetime import datetime, date, timedelta
import logging

log = logging.getLogger(__name__)

class Gallery(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self.discover_meta = DiscoverMeta(self._console_url, self._session)

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def upload_image(self, local_image):
        files = {'attachment': (open(local_image, 'rb'), 'application/octet-stream')}
        uri = self._console_url + '/__api/dashboard/image/upload'
        response = self._session.post(uri, files=files)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['url']

    def get_charts(self, groupId='-1'):
        uri = self._console_url + '/__api/dashboard/charts?page=1&size=100&groupId=%s' % groupId
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def get_chart_by_name(self, name):
        all_charts = self.get_charts()
        return[chart for chart in all_charts if chart['name'] == name][0]

    def get_chart_by_id(self, id):
        all_charts = self.get_charts()
        return[chart for chart in all_charts if chart['id'] == id][0]

    def add_chart(self, type, name, url=None, local_image=None, groupId='-1'):
        payload = {
            'groupId': groupId,
            'name': name,
            'url': url
        }

        if type == u'外部图片':
            payload['type'] = "ext.image"
            payload['chartType'] = "ImagePanel"
            assert url
            payload['url'] = url
        elif type == u'外部网页':
            payload['type'] = "ext.iframe"
            payload['chartType'] = "IframePanel"
            assert url
            payload['url'] = url
        elif type == u'上传图片':
            payload['type'] = "ext.upload"
            payload['chartType'] = "ImagePanel"
            assert local_image
            url = self.upload_image(local_image)
            payload['url'] = url

        uri = self._console_url + '/__api/dashboard/charts'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def update_chart(self, id, **kwargs):
        chart_data = self.get_chart_by_id(id=id)
        name = kwargs.pop('name', chart_data['name'])
        url = kwargs.pop('url', chart_data['url'])
        payload = {
            'groupId': chart_data['groupId'],
            'id': id,
            'name': name,
            'type': chart_data['type'],
            'url': url,
            'chartType': chart_data['chartType'],
        }

        uri = self._console_url + '/__api/dashboard/charts/' + id
        response = self._session.put(uri, json=payload)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def delete_chart(self, id):
        uri = self._console_url + '/__api/dashboard/charts/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    # def update_chart_shareType(self, id, **kwargs):
    #     share_data = self.get_chart_shareType(id=id)
    #     update_shareType = kwargs.pop('shareType', share_data['shareType'])
    #     update_users = kwargs.pop('users', share_data['users'])
    #     update_data = {
    #         'shareType': update_shareType,
    #         'users': update_users
    #     }
    #
    #     uri = self._console_url + '/__api/dashboard/charts/:%s/share' % id
    #     response = self._session.put(uri,json=update_data)
    #     response_content = json.loads(response.content)
    #     response_status_check(response_content['statusCode'], 0, response_content['messages'])
    #
