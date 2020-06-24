# -*- coding: utf-8 -*-

import json
import hashlib

from ._internal_utils import status_code_check, response_status_check
from .systemunit import SystemUnit
from .role import Role
from .tool import generate_menu_item_dict

import logging
log = logging.getLogger(__name__)


class User(object):
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
        """Get all users
        
        :return: user list
        """

        payload = {'paginate': False, 'pagination': {}, 'sorts': []}
        uri = self._console_url + "/__api/system/user/query"

        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def list_allUser(self):
        """Get local and LDAP users"""

        uri = self._console_url + "/__api/system/allUser/list"

        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content['data']['list']

    def get(self, id):
        """Get user by id
        
        :param id: user id
        :return: user info dict
        """

        uri = self._console_url + '/__api/system/user/' + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def get_by_name(self, name):
        """Get user info by user name
        
        :param name: user name
        :return: user info dict
        """

        user_list = self.list()
        return [user for user in user_list if user['loginName'] == name][0]

    def create_by_data(self, data):
        """Create user by data
        
        :param data: user data
        :return: None
        """

        uri = self._console_url + '/__api/system/user'
        response = self._session.post(uri, json=data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

        #return response_content['data']['id']

    def create(self, login_name=None, real_name=None, password=None, unit_name=None,
               email=None, mobile=None, roles=None, type=None, data=None, data_roles=None, **kwargs):
        """Create user
        
        :param login_name: refer to loginName, required
        :param real_name: refer to realName, required
        :param password: refer to loginPassword and repassword, required
        :param unit_name: refer to unitName, uiitId created by this, required
        :param email: refer to email
        :param mobile: refer to mobile
        :param roles: refer to roles, list format
        :param type: user type, local(value: 1) or ldap(value: 2)
        :param data: stereotypes of the parameters, do not need to construct.
        :param kwargs: other attrs
        :return: user id
        """

        if data:
            create_data = data
        else:
            assert login_name
            assert real_name
            assert password
            assert unit_name
            assert roles
            _system_unit = SystemUnit(self._console_url, self._session)
            unit_id = _system_unit.get_by_name(unit_name)['id']

            _role = Role(self._console_url, self._session)
            _role_list = [_role.get_by_name(r)['id'] for r in roles]

            m = hashlib.md5()
            m.update(password)

            create_data = {
                'loginName': login_name,
                'realName': real_name,
                'loginPassword': m.hexdigest(),
                'repassword': m.hexdigest(),
                'unitName': unit_name,
                'unitId': unit_id,
                'roles': _role_list,
                'email': '',
                'mobile': '',
                'type': 1,
                'dataroles': data_roles if data_roles else []
            }
            if email:
                create_data['email'] = email
            if mobile:
                create_data['mobile'] = mobile
            if type:
                assert (type in [1, 2])
                create_data['type'] = type
        return self.create_by_data(create_data)

    def update(self, id, data=None, **kwargs):
        """Update user
        
        :param id: user id
        :param data: update data
        :param kwargs: optional arguments to update user
        :return: None
        """

        uri = self._console_url + '/__api/system/user/' + id
        if data:
            update_data = data
            update_data['dataroles'] = data.pop('dataroles', [])
        else:
            user = self.get(id)
            update_data = {
                "id": id,
                "loginName": user['loginName'],
                "realName": user['realName'],
                "loginPassword": "",
                "repassword": "",
                "roles": [r['id'] for r in user['roles']],
                "dataroles": [],
                "unitId": user['unitId'],
                "email": user['email'] if user['email'] else '',
                "mobile": user['mobile'] if user['mobile'] else '',
                "type": user['type']
            }
        
        print update_data
        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def lock(self, id):
        """Lock user by id
        
        :param id: user id
        :return: None
        """

        uri = self._console_url + '/__api/system/user/' + id + '/lock'
        data = self.get(id)
        data['locked'] = 1
        response = self._session.put(uri, json=data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def unlock(self, id):
        """Unlock user by id
        
        :param id: user id
        :return: None
        """

        uri = self._console_url + '/__api/system/user/' + id + '/unlock'
        data = self.get(id)
        data['locked'] = 0
        response = self._session.put(uri, json=data)
        #print response.status_code, response.content
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def change_pwd(self, old_pwd, new_pwd):
        """Change user password
        
        :param old_pwd: old password
        :param new_pwd: new password
        :return: None
        """

        old_md5 = hashlib.new("md5", old_pwd).hexdigest()
        new_md5 = hashlib.new("md5", new_pwd).hexdigest()
        uri = self._console_url + '/__api/system/change-password'
        payload = {
            'originalPassword': old_md5,
            'newPassword': new_md5,
            'confirmNewPassword': new_md5,
        }

        response = self._session.put(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        """Delete user
        
        :param id: user id
        :return: None
        """

        uri = self._console_url + '/__api/system/user/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        status_code_check(response.status_code, 200)

    def delete_all(self):
        """Delete user

        :param id: user id
        :return: None
        """

        user_list = self.list()
        for user in user_list:
            try:
                self.delete(user['id'])
            except Exception as ex:
                print 'delete user exception', user['id']

    def get_login_info(self):
        """Get current login info
        
        :return: login info dict, menu and user
        """
        uri = self._console_url + "/__api/global/user/session"

        response = self._session.get(uri)
        response_content = json.loads(response.content)

        status_code_check(response.status_code, 200)
        #response_status_check(response_content['statusCode'], 0, response_content['messages'])

        return response_content

    def get_login_user(self):
        """Get current login user info
        
        :return: login user info dict
        """
        return self.get_login_info()['data']

    def get_login_menu(self):
        """Get current login menu info
        
        :return:  login menu list
        """
        login_info = self.get_login_info()
        print login_info
        b_super = True if login_info['data']['nickname'] == u'超级管理员' else False
        menus = login_info['data']['mainMenus']
        menu_list = []
        for menu in menus:
            if 'children' in menu:
                for child in menu['children']:
                    if b_super:
                        menu_list.append(generate_menu_item_dict(child['state'], 20))
                    else:
                        menu_list.append(generate_menu_item_dict(child['state'], child['allow_type']))
            else:
                if b_super:
                    menu_list.append(generate_menu_item_dict(menu['state'], 20))
                else:
                    menu_list.append(generate_menu_item_dict(menu['state'], menu['allow_type']))
        return menu_list

class LdapUser(object):
    def __init__(self, console_url, session=None):
        self._console_url = console_url
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def getNotSelected_user(self):
        uri = self._console_url + '/__api/system/ldap/users'
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def ldapUser_list(self):
        uri = self._console_url + '/__api/system/getLdapUsers'
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list']

    def add_User(self, username):
        uri = self._console_url + '/__api/system/createLdapUsers'
        ldap_user = self.ldapUser_list()
        notSelected_user = self.getNotSelected_user()
        user = [i for i in notSelected_user if i['loginName'] == username]
        ldap_user.insert(0, user[0])
        response = self._session.post(uri, json=ldap_user)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def get_by_name(self, name):
        uri = self._console_url + '/__api/system/LdapUserQuery/query'
        payload = {
            'paginate': False,
            'filters': [{
                'field': "loginName",
                'operator': 'like',
                'value': name
            }],
            'pagination': {'page': 1, 'pageSize': 20},
            'sort': []
        }
        response = self._session.post(uri, json=payload)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']['list'][0]

    def get_User(self, id):
        uri = self._console_url + '/__api/system/user/' + id
        response = self._session.get(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])
        return response_content['data']

    def update_User(self, id, unit_name="", roles="", data=None):
        uri = self._console_url + '/__api/system/updateLdapUser?id=' + id

        if data:
            update_data = data
        else:
            user = self.get_User(id)

            if unit_name:
                _system_unit = SystemUnit(self._console_url, self._session)
                unit_id = _system_unit.get_by_name(unit_name)['id']

            if roles:
                _role = Role(self._console_url, self._session)
                _role_list = [_role .get_by_name(role_name)['id'] for role_name in roles]

            update_data = {
                "id": id,
                "loginName": user['loginName'],
                "realName": user['loginName'],
                "loginPassword": "",
                "repassword": "",
                "roles": _role_list,
                "dataroles": [],
                "unitId": unit_id,
                "email": user['email'],
                "mobile": user['mobile'],
                "type": user['type']
            }

        response = self._session.put(uri, json=update_data)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def lock(self, id):
        uri = self._console_url + '/__api/system/user/' + id + '/lock'
        response = self._session.put(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def unlock(self, id):
        uri = self._console_url + '/__api/system/user/' + id + '/unlock'
        response = self._session.put(uri)
        response_content = json.loads(response.content)
        status_code_check(response.status_code, 200)
        response_status_check(response_content['statusCode'], 0, response_content['messages'])

    def delete(self, id):
        uri = self._console_url + '/__api/system/user/' + id
        header = {'Content-Type': 'application/json'}
        response = self._session.delete(uri, headers=header)
        status_code_check(response.status_code, 200)

    def delete_all(self):
        user_list = self.ldapUser_list()
        for user in user_list:
            try:
                self.delete(user['id'])
            except Exception as ex:
                print 'delete user exception', user['id']
