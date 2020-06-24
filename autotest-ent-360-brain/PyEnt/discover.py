# -*- coding: utf-8 -*-

import json

from .discovercharts import DiscoverCharts
from .discovermeta import DiscoverMeta
from ._internal_utils import status_code_check, response_status_check, convert_date_time

from datetime import datetime, date, timedelta
import logging

log = logging.getLogger(__name__)

class Discover(object):
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

    def get_timeline(self, source, filter_expression="", **kwargs):
        """
        get timeline
        :param source:
        :param timeFilter:
        :param filter_expression:
        :param kwargs:
        :return: timeline data
        """
        timeFilter = kwargs.pop('timeFilter', u'发生时间 >=now/d AND 发生时间 <now/d+1d')
        payload = {
            'source': source,
            'timeFilter': timeFilter,
            'filter': ""
        }
        if filter_expression:
            payload['filter'] = dict(FilterExpression=filter_expression)

        uri = self._console_url + '/__api/discover/get_timeline'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_discover_data(self, source, **kwargs):
        """
        Get data list
        :param source:
        :param timeFilter:
        :param field:
        :param filter_expression:
        :param kwargs:
        :return: data list
        """
        discover_meta = DiscoverMeta(self._console_url, self._session)

        field = kwargs.pop('field', discover_meta.defaultSelectedFields(source=source))
        timeFilter = kwargs.pop('timeFilter', u'发生时间 >=now/d AND 发生时间 <now/d+1d')
        filter_expression = kwargs.pop('filter_expression', None)

        columns = []
        for i in field:
            columns.append({'field': i, 'order': None, 'highlight': True})

        search = {
            'columns': columns,
            'from': 0,
            'size': 100
        }


        payload = {
            'source': source,
            'timeFilter': timeFilter,
            'search': search,
            'filter': ""
        }

        if filter_expression:
            payload['filter'] = dict(FilterExpression=filter_expression)

        uri = self._console_url + '/__api/discover/search'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_topn_list(self, source, field, filter_expression=None, **kwargs):
        """
        Get Field detail Info and Sort
        :param field:
        :param order:
        :param source:
        :param timeFilter:
        :param filter_expression:
        :return: Field detail Info
        """
        discover_meta = DiscoverMeta(self._console_url, self._session)
        field_key = discover_meta.get_field_key(source=source, field_name=field)

        timeFilter = kwargs.pop('timeFilter', u'发生时间 >=now/d AND 发生时间 <now/d+1d')
        order = kwargs.pop('order', "desc")

        payload = {
            'field': field_key,
            'order': order,
            'page': 1,
            'size': 100,
            'source': source,
            'filter': "",
            'timeFilter': timeFilter
        }
        if filter_expression:
            payload['filter'] = dict(FilterExpression=filter_expression)

        uri = self._console_url + '/__api/discover/get_topn'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def download(self, source,  **kwargs):
        """
        download table data
        :param source:
        :param timeFilter:
        :param selectedFields:
        :param filter_expression:
        :param kwargs:
        :return: download file id
        """
        discover_meta = DiscoverMeta(self._console_url, self._session)

        selectedFields = kwargs.pop('selectedFields', discover_meta.defaultSelectedFields(source=source))
        timeFilter = kwargs.pop('timeFilter', u'发生时间 >=now/d AND 发生时间 <now/d+1d')
        filter_expression = kwargs.pop('filter_expression', None)

        payload = {
            'source': source,
            'selectedFields': selectedFields,
            'timeFilter': timeFilter,
            'filter': ""
        }

        if filter_expression:
            payload['filter'] = dict(FilterExpression=filter_expression)

        uri = self._console_url + '/__api/discover/get_download_id'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def groups_list(self):
        """
        Get histories group list
        :return:histories group list
        """
        uri = self._console_url + '/__api/discover/groups'
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data'][0]

    def get_group_id(self, name):
        """
        Get history group id by name
        :param name:
        :return: group id
        """
        groups_list = self.groups_list()
        if name != "root":
            return [group['id'] for group in groups_list['children'] if group['name'] == name][0]
        else:
            return "-1"

    def get_group_by_id(self, id):
        """
        Get group info by id
        :param id:
        :return:group info
        """
        groups_list = self.groups_list()
        if id != "-1":
            return[group for group in groups_list['children'] if group['id'] == id][0]
        else:
            return groups_list[0]

    def add_group(self, name, parentId, description=""):
        """
        Add group
        :param name:
        :param description:
        :param parentId:
        :return: group id
        """
        group_data = {
            'name': name,
            'description': description,
            'parentId': parentId
        }

        uri = self._console_url + '/__api/discover/groups'
        response = self._session.post(uri, json=group_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def update_group(self, id, data=None, **kwargs):
        """
        update group info
        :param id:
        :param data:
        :param kwargs:
        :return:
        """
        if data:
            update_data = data
        else:
            group_data = self.get_group_by_id(id)
            name = kwargs.pop('name', None)
            description = kwargs.pop('description', None)
            if name:
                group_data['name'] = name
            if description:
                group_data['description'] = description
            update_data = {
                'id': id,
                'name': group_data['name'],
                'description': group_data['description']
            }

        uri = self._console_url + '/__api/discover/groups/' + id
        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_group(self, id):
        """
        delete group
        :param id:
        :return:
        """
        uri = self._console_url + '/__api/discover/groups/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, json=header)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete_all_group(self):
        group_list = self.groups_list()
        for group in group_list['children']:
            self.delete_group(group['id'])


    def get_histories_list(self, source, groupId="-1"):
        """
        get histories list
        :param source:
        :param groupId:
        :param page:
        :param size:
        :return: histories list
        """
        uri = self._console_url + '/__api/discover/histories?page=1&size=100&groupId=%s&source=%s' % (groupId, source)
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def get_history_id(self, source, name):
        """
        get history id by name
        :param name:
        :return: history id
        """
        list = self.get_histories_list(source=source)
        return[history['id'] for history in list if history['name'] == name][0]

    def delete_history(self, id):
        """
        delete history by id
        :param id:
        :return:
        """
        uri = self._console_url + '/__api/discover/histories/' + str(id)
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, json=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['id']

    def delete_all_history(self, source, groupId="-1"):
        histories_list = self.get_histories_list(source, groupId)
        for history in histories_list:
            print history['id']
            self.delete_history(history['id'])

    def get_history_data(self, id):
        """
        get history detail info by id
        :param id:
        :return: history detail info
        """
        uri = self._console_url + '/__api/discover/histories/' + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def save_to_history(self, source, name, publishType, group_name, **kwargs):
        """
        save Filters and Bi to history
        :param name:
        :param publishType:
        :param group_name:
        :param charts:
        :param globalFilter:
        :param filters:
        :param lockedFieldNum:
        :param source:
        :param time:
        :return:
        """

        discover_meta = DiscoverMeta(self._console_url, self._session)
        discover_charts = DiscoverCharts(self._console_url, self._session)
        selectedFields = discover_meta.defaultSelectedFields(source)
        groupId = self.get_group_id(group_name)

        filters = kwargs.pop('filters', [])
        globalFilter = kwargs.pop('globalFilter', "")
        time = kwargs.pop('time', {"type":"quick", "value":">=now/d,<now/d+1d"})
        lockedFieldNum = kwargs.pop('lockedFieldNum', 0)
        charts = discover_charts.default_chart()

        payload = {
            'charts': charts,
            'filters': filters,
            'globalFilter': globalFilter,
            'groupId': groupId,
            'lockedFieldNum': lockedFieldNum,
            'name': name,
            'publishType': publishType,
            'selectedFields': selectedFields,
            'source': source,
            'time': time
        }

        uri = self._console_url + '/__api/discover/histories'
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def update_history(self, history_id, data=None, **kwargs):
        discover_charts = DiscoverCharts(self._console_url, self._session)
        history_data = self.get_history_data(history_id)
        history_charts = discover_charts.get_history_charts(history_id)
        chart = [
                    {
                        'chartType': history_charts['list'][0]['chartType'],
                        'type': "bi",
                        'time': history_charts['list'][0]['time'],
                        'name': history_charts['list'][0]['name'],
                        'dimensions': history_charts['list'][0]['dimensions'],
                        'id': history_charts['list'][0]['id']
                    }
        ]

        update_data = {
            'charts': chart,
            'filters': history_data['filters'],
            'globalFilter': history_data['globalFilter'],
            'groupId': history_data['groupId'],
            'id': history_data['id'],
            'lockedFieldNum': history_data['lockedFieldNum'],
            'name': history_data['name'],
            'publishType': history_data['publishType'],
            'selectedFields': history_data['selectedFields'],
            'source': history_data['source'],
            'time': history_data['time'],
        }

        if data:
            update_data = data
        else:
            charts = kwargs.pop('charts', None)
            filters = kwargs.pop('filters', None)
            globalFilter = kwargs.pop('globalFilter', None)
            group_id = kwargs.pop('group_id', None)
            lockedFieldNum = kwargs.pop('lockedFieldNum', None)
            name = kwargs.pop('name', None)
            publishType = kwargs.pop('publishType', None)
            selectedFields = kwargs.pop('selectedFields', None)
            time = kwargs.pop('time', None)

            if charts:
                update_data['charts'] = charts
            if filters:
                update_data['filters'] = filters
            if globalFilter:
                update_data['globalFilter'] = globalFilter
            if group_id:
                update_data['groupId'] = group_id
            if lockedFieldNum:
                update_data['lockedFieldNum'] = lockedFieldNum
            if name:
                update_data['name'] = name
            if publishType:
                update_data['publishType'] = publishType
            if selectedFields:
                update_data['selectedFields'] = selectedFields
            if time:
                update_data['time'] = time

        uri = self._console_url + '/__api/discover/histories/' + history_id
        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

