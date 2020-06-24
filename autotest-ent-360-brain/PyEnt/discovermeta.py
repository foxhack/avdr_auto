# -*- coding: utf-8 -*-

import json

from .discovercharts import DiscoverCharts
from ._internal_utils import status_code_check, response_status_check, convert_date_time

from datetime import datetime, date, timedelta
import logging

log = logging.getLogger(__name__)


class DiscoverMeta(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get_meta(self, source):
        """
        Get DataSourceMeta
        :param source:
        :return: DataSourceMeta data
        """
        uri = self._console_url + '/__api/discover/meta?source=%s' % source
        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def defaultSelectedFields(self, source):
        meta_data = self.get_meta(source)
        print meta_data
        defaultSelectedFields = meta_data['defaultSelectedFields']
        return defaultSelectedFields

    def get_field_key(self, source, field_name):
        meta_data = self.get_meta(source)
        fields_list = meta_data['fields']
        return[field['key'] for field in fields_list if field['name'] == field_name][0]

