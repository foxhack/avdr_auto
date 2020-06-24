# -*- coding: utf-8 -*-

"""
Python library for Hansight Enterprise
"""

__title__ = 'pyent'
__version__ = '0.1'
__author__ = 'Cookie Zhang'

from .asset import Asset
from .assettype import AssetType
from .eventattribute import EventAttribute
from .eventtype import EventType
from .eventbase import EventBase
from .eventparser import EventParser
from .ceptemplate import CepTemplate
from .ceprule import CepRule, CEPRuleType
from .user import User
from .systemunit import SystemUnit
from .event import Event
from .license import License
from .alarm import Alarm
from .systemconfig import Intranet
from .systemconfig import SMTP
from .systemconfig import InitConfig
from .systemconfig import Notification
from .contexts import Contexts
from .intelligencegroup import IntelligenceGroup
from .intelligence import Intelligence
from .attack import Attack, AttackType
from .knowledge import Knowledge, KnowledgeType
from .ceptask import CepTask
from .intelligentanalysis import IntelligentAnalysis
from .dashboard import Dashboard
from .reporttemplate import ReportTemplate
from .assetview import AssetView
from .assetview import AssetBusiness
from .assetview import AssetDomain
from .assetview import AssetLocation
from .timereport import TimeReport
from .role import Role
from .auditlog import AuditLog
from .vulnerability import Vulnerability
from .dataviewer import DVCollector
from .dataviewer import DVParser
from .dataviewer import DVSource
from .connection import MySql
from .connection import SSH
from .systemconfig import LdapPolicy
from .systemconfig import SecurityPolicy
from .systemconfig import Mantainance
from .systemconfig import SystemTime
from .systemconfig import TiQuery
from .user import LdapUser
from .historytask import HistoryTask
from .elasticsearch import Elasticsearch
from .dataviewer import DVStore
from .ti import TIP
from .datarole import DataRole
from .discover import Discover
from .discovercharts import DiscoverCharts
from .discovermeta import DiscoverMeta
from .gallery import Gallery
from .whitelist import GlobalWhitelist, IntelligenceWhitelist
from .threat_ioc import ThreatIoc
from .incident import Incident
from .nta import NTA
from .systemconfig import Feedback
from .informationgroup import InformationGroup
from .information import Information
from .systemconfig import NotificationGroup
from .soar import Automation, Playbook, CaseManage

import session
import urlparse


# Set default logging handler to avoid "No handler found" warnings.
import logging
try:  # Python 2.7+
    from logging import NullHandler
except ImportError:
    class NullHandler(logging.Handler):
        def emit(self, record):
            pass

logging.getLogger(__name__).addHandler(NullHandler())


class PyEnt(object):
    def __init__(self, console_url, username=None, password=None, **kwargs):
        self._session = session.clean()
        self._console_url = console_url
        self._username = username
        self._password = password
        self._host = urlparse.urlparse(console_url).hostname

        self._event_attribute = EventAttribute(self._console_url, self._session)
        self._event_type = EventType(self._console_url, self._session)
        self._event_base = EventBase(self._console_url, self._session)
        self._event_parser = EventParser(self._console_url, self._session)
        self._cep_rule = CepRule(self._console_url, self._session)
        self._cep_template = CepTemplate(self._console_url, self._session)
        self._asset = Asset(self._console_url, self._session)
        self._asset_type = AssetType(self._console_url, self._session)
        self._user = User(self._console_url, self._session)
        self._system_unit = SystemUnit(self._console_url, self._session)
        self._event = Event(self._console_url, self._session)
        self._license = License(self._console_url, self._session)
        self._alarm = Alarm(self._console_url, self._session)
        self._intranet = Intranet(self._console_url, self._session)
        self._smtp = SMTP(self._console_url, self._session)
        self._cepruletype = CEPRuleType(self._console_url, self._session)
        self._contexts = Contexts(self._console_url, self._session)
        self._intelligence_group = IntelligenceGroup(self._console_url, self._session)
        self._intelligence = Intelligence(self._console_url, self._session)
        self._attack_type = AttackType(self._console_url, self._session)
        self._attack = Attack(self._console_url, self._session)
        self._knowledge_type = KnowledgeType(self._console_url, self._session)
        self._knowledge = Knowledge(self._console_url, self._session)
        self._ceptask = CepTask(self._console_url, self._session)
        self._intelligent_analysis = IntelligentAnalysis(self._console_url, self._session)
        self._dashboard = Dashboard(self._console_url, self._session)
        self._report_template = ReportTemplate(self._console_url, self._session)
        self._asset_view = AssetView(self._console_url, self._session)
        self._time_report = TimeReport(self._console_url, self._session)
        self._role = Role(self._console_url, self._session)
        self._auditlog = AuditLog(self._console_url, self._session)
        self._vulnerability = Vulnerability(self._console_url, self._session)
        self._dvcollector = DVCollector(self._console_url, self._session)
        self._dvparser = DVParser(self._console_url, self._session)
        self._dvsource = DVSource(self._console_url, self._session)
        self._asset_business = AssetBusiness(self._console_url, self._session)
        self._asset_domain = AssetDomain(self._console_url, self._session)
        self._asset_location = AssetLocation(self._console_url, self._session)
        self._init_config = InitConfig(self._console_url, self._session)
        self._notification = Notification(self._console_url, self._session)
        self._mysql = MySql(self._host)
        self._ssh = SSH(self._host)
        self._ldap_policy = LdapPolicy(self._console_url, self._session)
        self._security_policy = SecurityPolicy(self._console_url, self._session)
        self._ldap_user = LdapUser(self._console_url, self._session)
        self._history_task = HistoryTask(self._console_url, self._session)
        self._mantainance = Mantainance(self._console_url, self._session)
        self._systemTime = SystemTime(self._console_url, self._session)
        self._elasticsearch = Elasticsearch(self._host, self._session)
        self._dvstore = DVStore(self._console_url, self._session)
        self._tip = TIP(self._console_url, self._session)
        self._data_role = DataRole(self._console_url, self._session)
        self._discover = Discover(self._console_url, self._session)
        self._discover_charts = DiscoverCharts(self._console_url, self._session)
        self._discover_meta = DiscoverMeta(self._console_url, self._session)
        self._gallery = Gallery(self._console_url, self._session)
        self._globalwhitelist = GlobalWhitelist(self._console_url, self._session)
        self._intelligencewhitelist = IntelligenceWhitelist(self._console_url, self._session)
        self._tiquery = TiQuery(self._console_url, self._session)
        self._threat_ioc = ThreatIoc(self._console_url, self._session)
        self._incident = Incident(self._console_url, self._session)
        self._nta = NTA(self._console_url, self._session)
        self._feedback = Feedback(self._console_url, self._session)
        self._information_group = InformationGroup(self._console_url, self._session)
        self._information = Information(self._console_url, self._session)
        self._notification_group = NotificationGroup(self._console_url, self._session)
        self._soar_automation = Automation(self._console_url, self._session)
        self._soar_playbook = Playbook(self._console_url, self._session)
        self._soar_casemanage = CaseManage(self._console_url, self._session)

        if self._username and self._password:
            self.login()

    def login(self, username=None, password=None):
        username = username or self._username
        password = password or self._password
        self._session = session.login(self._console_url, username, password)
        self.update_session()

    def logout(self):
        session.logout(self._console_url, self._session)

    def update_session(self):
        self._event_parser.session = self._session
        self._event_type.session = self._session
        self._event_base.session = self._session
        self._event_attribute.session = self._session
        self._cep_rule.session = self._session
        self._cep_template.session = self._session
        self._asset.session = self._session
        self._asset_type.session = self._session
        self._user.session = self._session
        self._system_unit.session = self._session
        self._event.session = self._session
        self._license.session = self._session
        self._alarm.session = self._session
        self._intranet.session = self._session
        self._smtp.session = self._session
        self._cepruletype.session = self._session
        self._contexts.session = self._session
        self._intelligence_group.session = self._session
        self._intelligence.session = self._session
        self._attack_type.session = self._session
        self._attack.session = self._session
        self._knowledge_type.session = self._session
        self._knowledge.session = self._session
        self._ceptask.session = self._session
        self._intelligent_analysis.session = self._session
        self._dashboard.session = self._session
        self._report_template.session = self._session
        self._asset_view.session = self._session
        self._time_report.session = self._session
        self._role.session = self._session
        self._auditlog.session = self._session
        self._vulnerability.session = self._session
        self._dvcollector.session = self._session
        self._dvparser.session = self._session
        self._dvsource.session = self._session
        self._asset_business.session = self._session
        self._asset_domain.session = self._session
        self._asset_location.session = self._session
        self._init_config.session = self._session
        self._notification.session = self._session
        self._ldap_policy.session = self._session
        self._ldap_user.session = self._session
        self._history_task.session = self._session
        self._security_policy.session = self._session
        self._mantainance.session = self._session
        self._systemTime.session = self._session
        self._elasticsearch.session = self._session
        self._dvstore.session = self._session
        self._tip.session = self._session
        self._data_role.session = self._session
        self._discover.session = self._session
        self._discover_meta.session = self._session
        self._discover_charts.session = self._session
        self._gallery.session = self._session
        self._intelligencewhitelist.session = self._session
        self._tiquery.session = self._session
        self._threat_ioc.session = self._session
        self._globalwhitelist.session = self._session
        self._incident.session = self._session
        self._nta.session = self._session
        self._feedback.session = self._session
        self._information_group.session = self._session
        self._information.session = self._session
        self._notification_group.session = self._session
        self._soar_automation.session = self._session
        self._soar_playbook.session = self._session
        self._soar_casemanage.session = self._session

    def get_resource(self, resource):
        return {
            'EventAttribute': self._event_attribute,
            'EventType': self._event_type,
            'EventBase': self._event_base,
            'EventParser': self._event_parser,
            'CepTemplate': self._cep_template,
            'CepRule': self._cep_rule,
            'Asset': self._asset,
            'AssetType': self._asset_type,
            'User': self._user,
            'SystemUnit': self._system_unit,
            'Event': self._event,
            'License': self._license,
            'Alarm': self._alarm,
            'Intranet': self._intranet,
            'SMTP': self._smtp,
            'CEPRuleType': self._cepruletype,
            'Contexts': self._contexts,
            'IntelligenceGroup': self._intelligence_group,
            'Intelligence': self._intelligence,
            'AttackType': self._attack_type,
            'Attack': self._attack,
            'KnowledgeType': self._knowledge_type,
            'Knowledge': self._knowledge,
            'CepTask': self._ceptask,
            'IntelligentAnalysis': self._intelligent_analysis,
            'Dashboard': self._dashboard,
            'ReportTemplate': self._report_template,
            'AssetView': self._asset_view,
            'TimeReport': self._time_report,
            'Role': self._role,
            'AuditLog': self._auditlog,
            'Vulnerability': self._vulnerability,
            'DVCollector': self._dvcollector,
            'DVParser': self._dvparser,
            'DVSource': self._dvsource,
            'AssetBusiness': self._asset_business,
            'AssetDomain': self._asset_domain,
            'AssetLocation': self._asset_location,
            'InitConfig': self._init_config,
            'Notification': self._notification,
            'MySql': self._mysql,
            'SSH': self._ssh,
            'LdapPolicy': self._ldap_policy,
            'LdapUser': self._ldap_user,
            'HistoryTask': self._history_task,
            'SecurityPolicy': self._security_policy,
            'Mantainance': self._mantainance,
            'SystemTime': self._systemTime,
            'Elasticsearch': self._elasticsearch,
            'DVStore': self._dvstore,
            'TIP': self._tip,
            'DataRole': self._data_role,
            'Discover': self._discover,
            'DiscoverMeta': self._discover_meta,
            'DiscoverCharts': self._discover_charts,
            'Gallery': self._gallery,
            'GlobalWhitelist': self._globalwhitelist,
            'IntelligenceWhitelist': self._intelligencewhitelist,
            'TiQuery': self._tiquery,
            'ThreatIoc': self._threat_ioc,
            'Incident': self._incident,
            'NTA': self._nta,
            'Feedback': self._feedback,
            'InformationGroup': self._information_group,
            'Information': self._information,
            'NotificationGroup': self._notification_group,
            'Automation': self._soar_automation,
            'Playbook': self._soar_playbook,
            'CaseManage':self._soar_casemanage
        }.get(resource, None)

    def module_exec(self, module, func, **kwargs):
        resource = self.get_resource(module)
        if resource:
            return getattr(resource, func)(**kwargs)

    def execute_mysql_cmd(self, sql_cmd):
        return self._mysql.execute_sql_cmd(sql_cmd)

    def execute_ssh_cmd(self, ssh_cmd):
        return self._ssh.execute_remote_cmd(ssh_cmd)
    
    def get_debug_page(self, url_path):
        response = self._session.get("https://%s/%s" % (self._host, url_path), auth=('admin','op3ration'))
        assert response.status_code == 200