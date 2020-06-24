# -*- coding: utf-8 -*-

import poplib
import re
from retrying import retry

RE_GUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"


class QQExMail(object):

    def __init__(self):
        self.M = None

    @retry(stop_max_attempt_number=5)
    def mail_login(self, username, password, pop3_host="pop.exmail.qq.com", port=995, ssl=True):
        self.M = None
        if ssl:
            self.M = poplib.POP3_SSL(pop3_host, port)
        else:
            self.M = poplib.POP3(pop3_host, port)
        self.M.user(username)
        self.M.pass_(password)

    def message_count(self):
        return self.M.stat()[0]

    def get_mail(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        return self.get_content_from_message(response[1])

    def get_invitation_id(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        message = response[1]
        i = 0
        for j in message:
            i += 1
            if "Request Invitation ID:" in j:
                break
        if i == len(message):
            return None
        matchObj = re.search(RE_GUID, message[i+1])
        return matchObj.group()

    def get_invitation_code(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        message = response[1]
        for j in message:
            if j.startswith('size: 20px; font-weight: bold; color: #ffffff;">'):
                code = j[-17:-11]
                return code
        return None

    def get_active_link(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        content = self.get_content_from_message(response[1])
        RE_ACTIVE_LINK = r"http[s]?://[-.:a-zA-Z0-9]+/verify_user\?code=[0-9a-zA-Z]{6}"
        matchObj = re.findall(RE_ACTIVE_LINK, content)
        return matchObj[0]

    def get_reset_password_link(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        content = self.get_content_from_message(response[1])
        RE_ACTIVE_LINK = r"http[s]?://[-.:a-zA-Z0-9]+/uaa/reset_password\?code=[0-9a-zA-Z]{6}\&email=[.@%0-9a-zA-Z]+"
        matchObj = re.findall(RE_ACTIVE_LINK, content)
        return matchObj[0]

    def get_change_email_link(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        content = self.get_content_from_message(response[1])
        RE_ACTIVE_LINK = r"http[s]?://[-.:a-zA-Z0-9]+/verify_email\?code=[0-9a-zA-Z]{6}"
        matchObj = re.findall(RE_ACTIVE_LINK, content)
        return matchObj[0]

    def get_report_link(self, which):
        response = self.M.retr(which)
        assert response[0] == "+OK"
        content = self.get_content_from_message(response[1])
        RE_HTML_LINK = r"http[s]?://[-.:a-zA-Z0-9]+/api/report/templates/[-0-9a-z]{36}/[-0-9a-z]{36}/report.html"
        RE_PDF_LINK = r"http[s]?://[-.:a-zA-Z0-9]+/api/report/templates/[-0-9a-z]{36}/[-0-9a-z]{36}/report.pdf"
        matchObj_html = re.findall(RE_HTML_LINK, content)
        matchObj_pdf = re.findall(RE_PDF_LINK, content)
        return matchObj_html[0], matchObj_pdf[0]

    def get_content_from_message(self, message):
        content = ""
        bcontent = False
        for j in message:
            if j.startswith("<!DOCTYPE"):
                bcontent = True
            if j.startswith("------"):
                bcontent = False
            if bcontent:
                if j.endswith('code='):
                    content += j
                else:
                    content += j.strip('=')
        content = content.replace("=3D", "=")
        content = content.replace("&amp;", "&")
        return content

if __name__ == '__main__':
    instance = QQExMail()






