# -*- coding: utf-8 -*-

import os
import json
from ._internal_utils import status_code_check, response_status_check

import logging
log = logging.getLogger(__name__)


class SecurityScreen(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value