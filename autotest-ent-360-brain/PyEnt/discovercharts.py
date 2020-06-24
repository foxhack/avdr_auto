# -*- coding: utf-8 -*-

import json
import logging
from datetime import datetime, date, timedelta
import time

from ._internal_utils import status_code_check, response_status_check, convert_date_time

log = logging.getLogger(__name__)


class DiscoverCharts(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get_history_charts(self, history_id):
        """
        get history charts info by id
        :return:
        """
        uri = self._console_url + '/__api/discover/histories/%s/charts' % history_id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def time_config(self, timeType, **kwargs):
        time_type = {
            u'常用': 'quick',
            u'相对': 'relative',
            u'绝对': 'absolute'
        }
        if time_type[timeType] == 'quick':
            value = ">=now/d,<now/d+1d"
        if time_type[timeType] == 'relative':
            value = "1,d,false,0,s,false"
        if time_type[timeType] == 'absolute':
            start_time = int(time.mktime(time.strptime(str(date.today()), "%Y-%m-%d")))*1000
            end_time = int(time.mktime(time.strptime(str(date.today() + timedelta(days=1)), "%Y-%m-%d")))*1000
            value = str(start_time) + ',' + str(end_time)

        time_conf = {
            'type': time_type[timeType],
            'value': value
        }
        return time_conf

    def default_chart(self):
        dimension = [
            {
                'type': "metric",
                'field': "src_address",
                'level': 0,
                'color': "null",
                'metric': "count,thousands,2,false,__none__"
            },
            {
                'type': 'date_histogram',
                'field': "occur_time",
                'level': 2,
                'color': "null",
                'interval': "1,auto,YYYY-MM-DD HH:mm:ss"
            },
            {
                'type': 'term',
                'field': "event_name",
                'level': 1,
                'color': "null",
                'top': "metric,count,,desc,10"
             }
        ]
        default_chart = [
            {
                'chartType': "BarPanel",
                'type': "bi",
                'time': self.time_config(u"常用"),
                'name':  "test",
                'dimensions': dimension
            }
        ]
        return default_chart

    def dimensions(self):
        config_data = {
             "date_histogram": {
                     'type': "date_histogram",
                     'field': "occur_time",
                     'interval': {'type': "auto", 'value': 0}
             },
             "term": {
                    'type': "term",
                    'field': "event_name",
                    'top': {
                        'field': "src_address",
                        'metric': "count",
                        'order': "desc",
                        'type': "metric",
                        'value': 10
                    }
            },
            "metric": {
                 'type': "metric",
                 'field': "src_port",
                 'metric': "sum"
            },
            'columns': [
                    {'field': "occur_time", 'order': "desc"}, {'field': "event_name", 'order': None}
                ]
        }
        return config_data

    def dimension_conf(self, chartType):
        config_data = self.dimensions()
        if chartType == 'BarPanel':     ## 柱状图
            data = {
                'dimensions': [config_data["date_histogram"], config_data["term"], config_data["metric"]]
            }
        elif chartType == 'LinePanel':        ##  折现图
            data = {
                'dimensions': [config_data["date_histogram"], config_data["term"], config_data["metric"]]
            }

        elif chartType == 'PiePanel':     ##  环形图
            data = {
                'dimensions': [config_data["date_histogram"], config_data["metric"]]
            }
        elif chartType == 'AreaPanel':    ##  区域图
            data = {
                'dimensions': [config_data["date_histogram"], config_data["term"], config_data["metric"]]
            }
        elif chartType == 'TablePanel':       ##  明细表格
            data = {
                'search': {
                    'from': 0,
                    'size': 50,
                    'columns': config_data["columns"]
                }
            }
        elif chartType == 'AggTablePanel':    ## 聚合表格
            data = {
                'dimensions': [config_data["date_histogram"], config_data["term"], config_data["metric"]]
            }
        ## ## 统计图   chartType == 'StatPanel'
        else:
            data = {
                'dimensions': [config_data["metric"]]
            }
        return data

    def get_chart_ID(self, name, history_id):
        chart_list = self.get_history_charts(history_id)
        return[chart['id'] for chart in chart_list if chart['name'] == name][0]

    def get_chart_by_id(self, history_id, chart_id):
        chart_list = self.get_history_charts(history_id)
        return[chart for chart in chart_list if chart['id'] == chart_id][0]

    def config_chart(self, chartType, **kwargs):
        """
        config BI chart and return search api result
        :param name:
        :param chart_data:
        :param kwargs:
        :return: chart result
        """
        source = kwargs.pop('source', "event")
        data = kwargs.pop('dimensions',  self.dimension_conf(chartType))
        timeFilter = kwargs.pop('timeFilter', u"发生时间 >=now/d AND 发生时间 <now/d+1d")

        data['filter'] = ""
        data['source'] = source
        data['timeFilter'] = timeFilter

        uri = self._console_url + '/__api/discover/search'
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def update_charts(self, history_id, chart_id, update_data=None, **kwargs):
        if update_data:
            update_chart = update_data
        else:
            chart_data = self.get_chart_by_id(history_id, chart_id)
            chartType = kwargs.pop(kwargs['chartType'], chart_data['chartType'])
            time = kwargs.pop(kwargs['time'], chart_data['time'])
            name = kwargs.pop(kwargs['name'], chart_data['name'])
            dimensions = kwargs.pop(kwargs['dimensions'], chart_data['dimensions'])
            update_chart = [
                {
                    'chartType': chartType,
                    'type': "bi",
                    'time': time,
                    'name': name,
                    'dimensions': dimensions,
                    'id': chart_id
                }
            ]
        return update_chart

