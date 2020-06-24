# -*- coding: utf-8 -*-

import json
import hashlib
import re
from email.parser import Parser
from email.header import decode_header
import poplib
import time
from ceprule import CEPRuleType
from intelligencegroup import IntelligenceGroup
from assetview import AssetBusiness

from ._internal_utils import status_code_check, response_status_check

import logging

log = logging.getLogger(__name__)

class SMTP(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get(self):
        """Get SMTP server info
        
        :return: SMTP server info dict, better to check status
        """
        uri = self._console_url + '/__api/system/config/smtp'
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        #response_status_check(response_content['statusCode'], 0, response_content['messages'])
        #return response_content['data']
        return response_content

    def update(self, data=None, **kwargs):
        """Update SMTP server info
        
        :param data: SMTP data
        :param kwargs: optional arguments to update SMTP
        :return: None, better to check status
        """
        uri = self._console_url + '/__api/system/config/smtp'
        if data:
            update_data = data
        else:
            update_data = self.get()
            host = kwargs.pop('host', None)
            port = kwargs.pop('port', None)
            username = kwargs.pop('username', None)
            password = kwargs.pop('password', None)
            if host:
                update_data['host'] = host
            if port is not None:
                update_data['port'] = port
            if username:
                update_data['username'] = username
            if password:
                update_data['password'] = password

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        #response_status_check(response_content['statusCode'], 0, response_content['messages'])

class Notification(object):
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
        """Get all notify info
        :return: notify list
        """
        uri = self._console_url + "/__api/system/config/notification"
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get(self, id):
        """Get notify info by id

        :param id: notify id
        :return: notify info dict
        """
        uri = self._console_url + "/__api/system/config/notification/" + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_by_name(self, name):
        """Get notify info by name

        :param name: notify name
        :return: notify info dict
        """
        notify_list = self.list()
        return [notify for notify in notify_list if notify["name"] == name][0]

    def create_by_data(self, data):
        uri = self._console_url + "/__api/system/config/notification"
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def create(self, name=None, mailEnabled=0, emails=None, smsEnabled=0, phoneNumbers=None, cmdEnabled=0, cmd=None, data=None):
        if data:
            create_data = data
        else:
            assert name
            assert(mailEnabled or smsEnabled or cmdEnabled)
            if mailEnabled:
                assert emails
            if smsEnabled:
                assert phoneNumbers
            if cmdEnabled:
                assert cmd

            create_data = {
                "name": name,
                "mailEnabled": mailEnabled,
                "emails": emails,
                "smsEnabled": smsEnabled,
                "phoneNumbers": phoneNumbers,
                "cmdEnabled": cmdEnabled,
                "cmd": cmd
            }
        return self.create_by_data(create_data)

    def update(self, id, data=None, **kwargs):
        uri = self._console_url + "/__api/system/config/notification/" + id
        if data:
            update_data = data
        else:
            name = kwargs.pop('name', None)
            cmdEnabled = kwargs.pop("cmdEnabled", None)
            cmd = kwargs.pop("cmd", None)
            mailEnabled = kwargs.pop("mailEnabled", None)
            emails = kwargs.pop("emails", None)
            smsEnabled = kwargs.pop("smsEnabled", None)
            phoneNumbers = kwargs.pop("phoneNumbers", None)

            update_data = self.get(id)

            if name:
                update_data["name"] = name

            if cmdEnabled == 1:
                update_data["cmdEnabled"] = cmdEnabled
                update_data["cmd"] = cmd
            elif cmdEnabled == 0:
                update_data["cmdEnabled"] = 0

            if mailEnabled == 1:
                update_data["mailEnabled"] = mailEnabled
                update_data["emails"] = emails
            elif mailEnabled == 0:
                update_data["mailEnabled"] = 0

            if smsEnabled == 1:
                update_data["smsEnabled"] = smsEnabled
                update_data["phoneNumbers"] = phoneNumbers
            elif smsEnabled == 0:
                update_data["smsEnabled"] = 0


        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        id = ','.join(id)
        uri = self._console_url + "/__api/system/config/notification/" + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)


    def checkMail(self, server, username, password):
        s = poplib.POP3(server)
        s.user(username)
        s.pass_(password)
        resp, mails, octets = s.list()
        index = len(mails)
        resp, lines, octets = s.retr(index)
        msg_content = b'\r\n'.join(lines).decode('utf-8')
        msg = Parser().parsestr(msg_content)
        subject = msg.get('Subject')
        subject, charset = decode_header(subject)[0]
        if charset:
            subject = subject.decode(charset)
        return subject

class NotificationGroup(object):
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
        """Get all notify info
        :return: notify list
        """
        uri = self._console_url + "/__api/system/config/notification_group"
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get(self, id):
        """Get notify info by id

        :param id: notify id
        :return: notify info dict
        """
        uri = self._console_url + "/__api/system/config/notification_group/" + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_by_name(self, name):
        """Get notify info by name

        :param name: notify name
        :return: notify info dict
        """
        notify_group_list = self.list()
        return [notify_group for notify_group in notify_group_list if notify_group["name"] == name][0]

    def policy_data(self, data_type, value):
        """
         配置通知策略组的过滤条件
        :param data_type: 过滤条件类型
        :param value: 条件类型对应的值
        :return: policy
        """
        originFilter = '%s = "%s"' % (data_type, value)
        translatedFilter = ""
        value = value.split('/')[-1]
        if data_type == u"安全事件等级":
            severity_value = {
                u"提醒": 0,
                u"警告": 1,
                u"严重": 2,
                u"致命": 3
            }
            translatedFilter = "severity = %s" % severity_value[value]

        elif data_type == u"关联告警类型":
            attackBehavior = CEPRuleType(self._console_url, self._session)
            ruleType_data = attackBehavior.get_by_name(value)
            translatedFilter = "belongAttackBehavior(*, '%s')" % ruleType_data['id']

        elif data_type == u"资产业务域":
            assetDomain = AssetBusiness(self._console_url, self._session)
            assetDomain_data = assetDomain.get_by_name(value)
            translatedFilter = "belongAssetDomain(*, '%s')" % assetDomain_data['id']

        elif data_type == u"影响资产":
            intelligenceGroup = IntelligenceGroup(self._console_url, self._session)
            intelligenceGroup_data = intelligenceGroup.get_by_name(value)
            translatedFilter = "belongAsset(*, '%s')" % intelligenceGroup_data['id']

        policy = {
            "originFilter": originFilter,
            "translatedFilter": translatedFilter
        }
        return policy

    def create_by_data(self, data):
        uri = self._console_url + "/__api/system/config/notification_group"
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def create(self, name=None, notify_id=None, policy=None, data=None):
        """
        新增通知策略
        :param name:
        :param notify_id:
        :param policy:
        :param data:
        :return:
        """
        if data:
            create_data = data
        else:
            assert name
            assert notify_id
            assert policy

            create_data = {
                "id": "",
                "name": name,
                "notification": notify_id,
                "policy": policy,
                "system": 0,
                "enable": 1
            }
        return self.create_by_data(create_data)

    def update(self, id, **kwargs):
        """
        更新通知策略组
        :param id:
        :param kwargs:
        :return:
        """
        uri = self._console_url + "/__api/system/config/notification_group/" + id
        update_data = self.get(id)

        name = kwargs.pop('name', None)
        notify_id = kwargs.pop('notify_id', None)
        policy = kwargs.pop('policy', None)

        if name:
            update_data['name'] = name
        if notify_id:
            update_data['notification'] = notify_id
        if policy:
            update_data['policy'] = policy
            update_data['config'] = str(policy)

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        id = ','.join(id)
        uri = self._console_url + "/__api/system/config/notification_group/" + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)

class Intranet(object):
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
        """Get all intranet info

        :return: intranet list
        """

        uri = self._console_url + "/__api/system/config/intranet?page=1&size=20"

        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        intranet_list = response_content['data']['list']
        for intranet in intranet_list:
            intranet['config'] = json.loads(intranet['config'])
        return intranet_list

    def get(self, id):
        """Get intranet info by id
        
        :param id: intranet id
        :return: intranet info dict
        """
        uri = self._console_url + '/__api/system/config/intranet/' + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_by_name(self, name):
        """Get intranet info by name
        
        :param name: intranet name
        :return: in intranet info dict
        """
        intranet_list = self.list()
        return [intranet for intranet in intranet_list if intranet['config']['name'] == name][0]

    def create_by_data(self, data):
        """Create intranet by data
        
        :param data: intranet data
        :return: None, better to return intranet id created
        """
        uri = self._console_url + "/__api/system/config/intranet"
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        #return response_content['data']['id']

    def create(self, name=None, intranet=None, longitude=None, latitude=None, data=None, **kwargs):
        """Create intranet
        
        :param name: name, refer to name
        :param intranet: intranet list, refer to intranet
        :param longitude: longitude, refer to longitude
        :param latitude: latitude, refer to latitude
        :param data: intranet data
        :param kwargs: other attrs
        :return: None
        """
        if data:
            create_data = data
        else:
            assert name
            assert intranet
            assert longitude is not None
            assert latitude is not None
            create_data = {
                'name': name,
                'geo': {
                    'longitude': longitude,
                    'latitude': latitude
                },
                'intranet': intranet
            }
        return self.create_by_data(create_data)

    def update(self, id, data=None, **kwargs):
        """Update intranet
        
        :param id: intranet id
        :param data: update data
        :param kwargs: optional arguments to update intranet
        :return: None
        """
        uri = self._console_url + '/__api/system/config/intranet/' + id
        if data:
            update_data = data
        else:
            update_data = self.get(id)
            name = kwargs.pop('name', None)
            longitude = kwargs.pop('longitude', None)
            latitude = kwargs.pop('latitude', None)
            intranet = kwargs.pop('intranet', None)
            if name:
                update_data['name'] = name
            if longitude is not None:
                update_data['geo']['longitude'] = longitude
            if latitude is not None:
                update_data['geo']['latitude'] = latitude
            if intranet:
                update_data['intranet'] = intranet

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])


    def delete(self, id):
        """Delete intranet by id
        
        :param id: intranet id
        :return: None
        """
        uri = self._console_url + "/__api/system/config/intranet/" + id
        response = self._session.delete(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)


class InitConfig(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session
        self._types = {
            'event': ['Event'],
            'parser': ['Event', 'ParseRule'],
            'intelligence': ['Intelligence'],
            'knowledge': ['Knowledge_AttackData'],
            'cep': ['Event', 'Intelligence', 'CEP_Analysis'],
            'component': ['Component'],
            'dashboard': ['Component', 'Dashboard'],
        }

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def import_module(self, local_file):
        """Import information
        
        :param local_file: local file to import
        :return: None
        """
        uri = self._console_url + '/__api/system/config/import?locale=zh_cn'
        files = {'attachment': open(local_file, 'rb')}
        response = self._session.post(uri, files=files)
        response_content = json.loads(response.content)
        print response.content

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def export_module(self, local_file, args=[]):
        """Export information
        
        :param local_file: filename to store
        :param args: modules to export
        :return: None
        """
        uri = self._console_url + '/__api/system/config/export/'
        modules = set()
        for i in args:
            j = self._types.get(i, None)
            if j:
                modules.update(j)
        uri = uri + ','.join(modules)
        response = self._session.get(uri)
        status_code_check(response.status_code, 200)
        with open(local_file, 'wb') as pf:
            pf.write(response.content)


class LdapPolicy(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get(self):
        uri = self._console_url + '/__api/system/ldapPolicy'
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def import_ca_file(self, filePath):
        # need to update the token
        uri = self._console_url + '/__api/system/ldap/config/import'
        assert filePath
        response = self._session.post(uri, json=filePath)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def config_by_data(self, data):
        uri = self._console_url + '/__api/system/ldapPolicy'
        if data['ssl_enabled']:
            self.import_ca_file(data['ca_file'])
        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def config(self, bind_dn=None, password=None, base_dn=None, ip=None, port=None, ssl_enabled=False, ca_file=None, sync_interval=1, data=None):
        if data:
            config_data = data
        else:
            assert bind_dn
            assert password
            assert base_dn
            assert ip
            assert port
            assert sync_interval is not None
            assert bind_dn

            if ssl_enabled:
                self.import_ca_file(ca_file)

            config_data = {
                "bind_dn": bind_dn,
                "password": password,
                "base_dn": base_dn,
                "ip": ip,
                "port": port,
                "ssl_enabled": ssl_enabled,
                "ca_file": ca_file,
                "sync_interval": sync_interval,
            }
        return self.config_by_data(config_data)

    def update(self, data=None, **kwargs):
        uri = self._console_url + '/__api/system/ldapPolicy'
        if data:
            update_data = data
        else:
            update_data = self.get()
            bind_dn = kwargs.pop('bind_dn', None)
            password = kwargs.pop('password', None)
            base_dn = kwargs.pop('base_dn', None)
            ip = kwargs.pop('ip', None)
            port = kwargs.pop('port', None)
            ssl_enabled = kwargs.pop('ssl_enabled', None)
            ca_file = kwargs.pop('ca_file', None)
            sync_interval = kwargs.pop('sync_interval', None)
            if bind_dn is not None:
                update_data['bind_dn'] = bind_dn
            if password is not None:
                update_data['password'] = password
            if base_dn is not None:
                update_data['base_dn'] = base_dn
            if ip is not None:
                update_data['ip'] = ip
            if port is not None:
                update_data['port'] = port
            if ssl_enabled is not None:
                update_data['ssl_enabled'] = ssl_enabled
            if ca_file is not None:
                update_data['ca_file'] = ca_file
            if sync_interval is not None:
                update_data['sync_interval'] = sync_interval

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

class SecurityPolicy(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get(self):
        uri = self._console_url + '/__api/system/securityPolicy'
        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def config_by_data(self, data):
        uri = self._console_url + '/__api/system/securityPolicy'

        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def config(self, data=None, **kwargs):
        if data:
            config_data = data
        else:
            pwdMin = kwargs.pop('pwdMin', None)
            pwdUppercase = kwargs.pop('pwdUppercase', None)
            pwdLowercase = kwargs.pop('pwdLowercase', None)
            pwdNumber = kwargs.pop('pwdNumber', None)
            pwdSpecial = kwargs.pop('pwdSpecial', None)

            attemptLoginUnlock = kwargs.pop('attemptLoginUnlock', None)
            attemptLoginTime = kwargs.pop('attemptLoginTime', None)
            autoUnlockTime = kwargs.pop('autoUnlockTime', None)

            tokenEnabled = kwargs.pop('tokenEnabled', None)
            tokenExpiration = kwargs.pop('tokenExpiration', None)

            passwordExpirationEnabled = kwargs.pop('passwordExpirationEnabled', None)
            passwordExpiration = kwargs.pop('passwordExpiration', None)

            ipLimit = kwargs.pop('ipLimit', None)
            ipWhitelist = kwargs.pop('ipWhitelist', None)

            config_data = self.get()
            if pwdMin is not None:
                config_data['pwdMin'] = pwdMin
            if pwdUppercase is not None:
                config_data['pwdUppercase'] = pwdUppercase
            if pwdLowercase is not None:
                config_data['pwdLowercase'] = pwdLowercase
            if pwdNumber is not None:
                config_data['pwdNumber'] = pwdNumber
            if pwdSpecial is not None:
                config_data['pwdSpecial'] = pwdSpecial

            if attemptLoginUnlock is not None:
                config_data['attemptLoginUnlock'] = attemptLoginUnlock
                if attemptLoginUnlock:
                    if attemptLoginTime is not None:
                        config_data['attemptLoginTime'] = attemptLoginTime
                    if autoUnlockTime is not None:
                        config_data['autoUnlockTime'] = autoUnlockTime

            if tokenEnabled is not None:
                config_data['tokenEnabled'] = tokenEnabled
                if tokenEnabled:
                    if tokenExpiration is not None:
                        config_data['tokenExpiration'] = tokenExpiration

            if passwordExpirationEnabled is not None:
                config_data['passwordExpirationEnabled'] = passwordExpirationEnabled
                if passwordExpirationEnabled:
                    if passwordExpiration is not None:
                        config_data['passwordExpiration'] = passwordExpiration

            if ipLimit is not None:
                config_data['ipLimit'] = ipLimit
                if ipLimit:
                    assert ipWhitelist
                    config_data['ipWhitelist'] = ipWhitelist

        return self.config_by_data(config_data)

class Mantainance(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get(self):
        uri = self._console_url + '/__api/system/config/mantainance'
        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def config(self, isValid=None, firstThreshold=None, retainDay=None, secondThreshold=None, data=None):
        uri = self._console_url + '/__api/system/config/mantainance'

        if data:
            config_data = data
        else:
            config_data = {"firstThreshold":"80","isValid":True,"retainDay":"180","secondThreshold":"90"} #self.get()
            if isValid is not None:
                config_data['isValid'] = True
                if isValid:
                    if firstThreshold is not None:
                        config_data['firstThreshold'] = firstThreshold
                    if retainDay is not None:
                        config_data['retainDay'] = retainDay
                    if secondThreshold is not None:
                        config_data['secondThreshold'] = secondThreshold

        response = self._session.put(uri, json=config_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def set_index_keep_days(self, name, days=None):
        uri = self._console_url + '/__api/system/config/storage/maintenance'
        data = {
            "index": name,
            "days": int(days)
        }

        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def generate_datetime_by_days(self, start, end, interval=24*3600):
        data = []
        start_time = int(time.mktime(time.strptime("%s" % start, "%Y-%m-%d %H:%M:%S")))
        end_time = int(time.mktime(time.strptime("%s" % end, "%Y-%m-%d %H:%M:%S")))

        current_time = start_time
        while current_time < end_time:
            data.append(current_time*1000)
            current_time = current_time + interval

        return data

class SystemTime(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get_time(self):
        uri = self._console_url + '/__api/system/config/getSystemTime'
        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def set_time(self, time):
        """time is a timestamp"""
        uri = self._console_url + '/__api/system/config/setSystemTime'
        data = {"time":time}
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

class TiQuery(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def get_tiquery_status(self):
        '''
        Get the status of ti query configuration.
        :return:
        '''
        uri = self._console_url + '/__api/system/config/tiQuery?locale=zh_cn'
        response = self._session.get(uri, headers={"Content-Type": "application/json;charset=UTF-8"}, verify=False)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def set_ti_query(self, alarmEnabled=True, eventEnabled=False):
        '''
        Set the ti query configuration based on event or alarm.
        :return:
        '''
        uri = self._console_url + '/__api/system/config/tiQuery'
        payload = {
            "alarmEnabled": alarmEnabled,
            "eventEnabled": eventEnabled
        }
        print payload
        response = self._session.put(uri, json=payload, verify=False)
        print response.url
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

class Feedback(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def enable_feedback(self, status):
        '''
        Enable or Disable feedback
        status:  0 (Disable), 1 (Enable)
        '''
        uri = self._console_url + '/__api/system/config/cloudDetectSettings'
        payload = {"queryEnabled": bool(int(status))}

        response = self._session.put(uri, json=payload, verify=False)

        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])