# -*- coding: utf-8 -*-

import json


class Elasticsearch(object):
    def __init__(self, es_ip, session=None):
        self._es_url = "http://%s:9200" % es_ip
        self._session = session

    @property
    def session(self):
        return self._session

    @session.setter
    def session(self, value):
        self._session = value

    def query_index_doc_count(self, index_name, condition_data):
        """
        Query the doc total count of the index
        :param index_name: the name of index
        :param condition_data: the querying condition
        :return: index doc count
        """
        uri = self._es_url + "/%s/_search?search_type=count" % index_name
        data = {"query":{"match":condition_data}}

        response = self.session.post(uri, json=data, verify=False)
        r = json.loads(response.content)
        return int(r["hits"]["total"])

    def query_cnt_ti_related_info(self, ioc_data=""):
        """
        Query index threat_intelligence_related_info doc count by condition
        :param ioc_data: the querying ioc value
        :return: index doc count
        """
        index = "threat_intelligence_related_info"
        query_data = {"ioc": ioc_data}

        return self.query_index_doc_count(index, query_data)

    def delete_index(self, index_name="*"):
        """
        Delete index, delete all by default 
        """
        uri = self._es_url + "/%s" % index_name

        response = self.session.delete(uri, verify=False)
        return json.loads(response.content)

    def query_cnt_ti_port(self, port=""):
        """
        Query index threat_intelligence_port doc count by condition
        :param port: the querying port value
        :return: index doc count
        """
        index = "threat_intelligence_port"
        query_data = {"portlist.port": port}

        return self.query_index_doc_count(index, query_data)

    def flush_es_event_index(self):
        uri = self._es_url + '/event*/_refresh'
        self.session.post(uri, verify=False)

    def get_valid_ioc(self, type):
        '''
        Get the valid ioc in 30 days.
        :return:
        '''
        url = self._es_url + '/threat_intelligence_credibility/_search?pretty'
        payload = {"query": {"match": {"type":type}}, "sort": {"timestamp": "desc"}, "size": 2}
        response = self._session.post(url, json=payload)
        response_content = json.loads(response.content)
        if response.status_code == 200:
            list_ioc = []
            for item in response_content['hits']['hits']:
                list_ioc.append(item['_source']['ioc'])
            return list_ioc

    def get_ioc_details_from_es(self, ioc):
        '''
        Get the detailed ioc info from elasticsearch.
        :param ioc: ioc
        :return: ioc info
        '''
        url = self._es_url + '/threat_intelligence/_search?pretty'
        payload = {"query": {"match": {"ioc": ioc}}}
        response = self._session.post(url, json=payload)
        response_content = json.loads(response.content)
        if response.status_code == 200 :
            print response_content['hits']['hits'][0]['_source']
            return response_content['hits']['hits'][0]['_source']