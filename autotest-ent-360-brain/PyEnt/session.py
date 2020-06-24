# -*- coding: utf-8 -*-

import requests
import hashlib
import json
from hashlib import md5
from requests.packages.urllib3.exceptions import InsecureRequestWarning
from . import __title__, __version__
from ._internal_utils import status_code_check, response_status_check

import logging
log = logging.getLogger(__name__)

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

def clean():
    user_agent = '{0}/{1}'.format(__title__, __version__)
    with requests.Session() as session:
        session.headers.update({'user-agent': user_agent})
        session.verify = False
    return session


def login(console_url, username, password):
    session = requests.Session()
    session.verify = False
    session.headers['Referer'] = console_url
    m = md5()
    m.update(password)
    url = console_url + '/__api/global/user/login?locale=zh_cn'
    data = {
        "username": username,
        "password": m.hexdigest(),
        "captcha": "bypass"
    }

    response = session.post(url, json=data)
    response_content = json.loads(response.content)
    response_status_check(response_content['statusCode'], 0, response_content['messages'])

    return session


def logout(console_url, session):
    # Todo: logout session from server
    url = console_url + '/__api/global/user/logout'

    session.get(url)


def check_status(console_url, session):
    uri = console_url + "/api/node/menus"
    response = session.get(uri)
    status_code_check(response.status_code, 200)


