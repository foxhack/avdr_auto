import requests
from browsers import browser_user_agent
import json
from retrying import retry


class QQExMailManager(object):
    def __init__(self):
        self.token_url = "https://exmail.qq.com/cgi-bin/token"
        self.api_url = "http://openapi.exmail.qq.com:12211/openapi"
        self.user_agent = browser_user_agent["chrome_52"]
        self.session = None

    @retry(stop_max_attempt_number=5)
    def init_session(self, client_id, client_secret):
        """
        Init Session, get the access token
        :param client_id: client_id
        :param client_secret: client_secret
        :return:
        """
        with requests.Session() as session:
            session.headers.update({'user-agent': self.user_agent})
            params = {
                "grant_type": "client_credentials",
                "client_id": client_id,
                "client_secret": client_secret
            }
            response = session.post(self.token_url, params=params)
        assert response.status_code == 200
        result = json.loads(response.content)
        session.headers.update({'Authorization': result["token_type"] + " " + result["access_token"]})
        self.session = session

    @retry(stop_max_attempt_number=5)
    def create_user(self, username, email, password):
        """
        Create a new use on qq exmail
        :param username: username
        :param email: user email
        :param password: password
        :return:
        """
        sync_url = self.api_url + "/user/sync"
        params = {
            "action": "2",
            "name": username,
            "alias": email,
            "password": password
        }
        response = self.session.post(sync_url, params=params, verify=False)
        print response.content
        assert response.status_code == 200

    @retry(stop_max_attempt_number=5)
    def delete_user(self, email):
        """
        Delete a user from qq exmail
        :param email: user's email
        :return:
        """
        sync_url = self.api_url + "/user/sync"
        params = {
            "action": "1",
            "alias": email,
        }
        response = self.session.post(sync_url, params=params)
        print response.content
        assert response.status_code == 200
        result = json.loads(response.content)


if __name__ == '__main__':
    instance = QQExMailManager()
