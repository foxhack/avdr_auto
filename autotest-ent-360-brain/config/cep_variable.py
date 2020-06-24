# -*- coding: utf-8 -*-

#collector parse rules
collector_rule_name_list = [ur'WAF_绿盟_通用_1', ur'WAF_绿盟_通用_5']

#invalid cep rule dict
invalid_cep_rule_info_dict = {
    'rule_name': u'通用web攻击',
    'valid_rule_type_name': u'普通攻击',
    'valid_temp_name': u'普通模板',
    'invalid_rule_type_name': 'invalid rule type',
    'invalid_temp_name': 'invalid template',
}

#cep rule from file
cep_rule_with_normal_template = 'testdata/ceprule/normal.txt'
cep_rule_with_having_count_template = 'testdata/ceprule/having_count.txt'
cep_rule_with_having_sum_template = 'testdata/ceprule/having_sum.txt'
cep_rule_with_count_distinct_template = 'testdata/ceprule/count_distinct.txt'
cep_rule_with_follow_by_template = 'testdata/ceprule/follow_by.txt'
cep_rule_with_repeat_until_template = 'testdata/ceprule/repeat_until.txt'

# cep rule import & export test variable
cep_rule_update_desc = 'import check test'
cep_rule_buildin_no_update = {
    'rule_name': u'linux删除用户',
    'path': 'testdata/ceprule/buildin_import_no_update'
}
cep_rule_buildin_import_skip = {
    'rule_name': u'linux新建用户',
    'path': 'testdata/ceprule/buildin_import_skip'
}
cep_rule_buildin_import_overwrite = {
    'rule_name': u'linux服务器硬盘故障',
    'path': 'testdata/ceprule/buildin_import_overwrite'
}
cep_rule_buildin_import_rename = {
    'rule_name': u'linux服务器系统重启',
    'path': 'testdata/ceprule/buildin_import_rename'
}

cep_rule_add = {
    'rule_name': 'cep_rule_import_check',
    'path': 'testdata/ceprule/added_import_check'
}
cep_rule_export = u'linux服务器服务启动失败'

# event attr check
event_attr_check = {
    'event_name': u'web访问',
    'attrs': ['src_address', 'dst_address']
}
