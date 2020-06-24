# -*- coding: utf-8 -*-

import json
import time
from ._internal_utils import status_code_check, response_status_check, convert_date_time, EntityType, ShareType, ReportFileFormat
from datetime import datetime, date, timedelta
import logging

log = logging.getLogger(__name__)


class HistoryTask(object):
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
        uri = self._console_url + '/__api/cep/tasks'

        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def get_task(self, name):
        task_list = self.list()
        return [task for task in task_list if task['name'] == name][0]

    def get_by_id(self, id):
        task_list = self.list()
        return [task for task in task_list if task['id'] == id][0]

    def create_by_data(self, create_data):
        uri = self._console_url + '/__api/cep/tasks'

        response = self._session.post(uri, json=create_data)
        response_content = json.loads(response.content)
        # status_code_check(response.status_code, 200)
        # response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def create(self, name=None, ruleId_list=None, beginTime=date.today(), endTime=date.today() + timedelta(days=2), description="", cron="", data=None):
        if data is not None:
            create_data = date
        else:
            assert name
            assert beginTime
            assert endTime
            assert ruleId_list
            create_data = {
                'name': name,
                'beginTime': convert_date_time(datetime.strptime(str(beginTime), '%Y-%m-%d')),
                'endTime': convert_date_time(datetime.strptime(str(endTime), '%Y-%m-%d')),
                'relativeRule': ruleId_list,
                'cron': cron,
                'description': description
            }
        return self.create_by_data(create_data)

    def delete(self, id):
        uri = self._console_url + '/__api/cep/tasks/' + str(id)

        response = self._session.delete(uri)
        # response_content = json.loads(response.content)
        # status_code_check(response.status_code, 200)
        # response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def alarmHistory(self, endTime, beginTime, id):
        uri = self._console_url + '/__api/alarmHistory/trend?endTime=%s&jobId=%s&startTime=%s' % (endTime, id, beginTime)
        response = self._session.post(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']
