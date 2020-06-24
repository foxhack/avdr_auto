# -*- coding: utf-8 -*-

import json
import mysql.connector as msql
from ._internal_utils import status_code_check, response_status_check


class TIP(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def register(self, ip, port, key, sslenabled=1):
        """
        Register to TIP
        """
        enable = True
        if int(sslenabled) != 1:
            enable = False

        uri = self._console_url + '/__api/system/config/tip'
        payload = {"webUrl": ip, "port": int(port),
                   "secretKey": key,
                   "sslEnabled": enable}

        response = self._session.put(uri, json=payload)
        status_code_check(response.status_code, 200)


    def unregister(self):
        """
        Unregister TIP
        """

        uri = self._console_url + '/__api/system/config/tip'
        header = {'Content-Type': 'application/json'}

        response = self._session.delete(uri, headers=header)
        status_code_check(response.status_code, 200)

    def get_apikey_from_tip(self, tip_ip):
        """
        Query apikey from TIP DB
        """
        conn = msql.connect(host=tip_ip, user='hansight', password='hansight', database='hansight-tip', use_unicode=True, port=3399)
        sql = 'SELECT token FROM api_token WHERE id=2 AND type=2'

        cursor = conn.cursor()
        cursor.execute(sql)
        output = cursor.fetchall()
        cursor.close()
        return output[0][0]

