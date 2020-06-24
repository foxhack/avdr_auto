*** Settings ***
Documentation     Test for DV function
Test Setup        TestSetup
Test Teardown     TestTeardown
Resource          kw_ent.robot
Resource          kw_utils.robot
Resource          kw_event.robot
Resource          kw_dataviewer.robot

*** Variables ***
${eport_import_rule_file}    local_dv_rule_file
${rule_name_for_delete}    test_delete
${default_builtin_rule_name}    netflow
${export_import_rule_for_test}    test_分隔符
${kafka_db_file_source_test}    test_URL映射
${local_ip}    127.0.0.1
${default_es_store_name}    Enterprise-ES

*** Test Cases ***
Create new DV parser rule
    [Tags]    dataviewer
    Run Keyword and Expect Error    *    Get DV Parser    ${rule_name_for_delete}
    Run Keyword and Ignore Error    Create DV Parser With Post Data File    testdata/dv/new_dv_parser.json
    Get DV Parser    name=${rule_name_for_delete}

Create duplicated name DV parser rule
    [Tags]    dataviewer
    Run Keyword and Ignore Error    Create DV Parser With Post Data File    testdata/dv/new_dv_parser.json
    Run Keyword and Expect Error    *    Create DV Parser With Post Data File    testdata/dv/new_dv_parser.json

Delete DV parser rule
    [Tags]    dataviewer
    Run Keyword and Ignore Error    Create DV Parser With Post Data File    testdata/dv/new_dv_parser.json
    Delete DV Parser    name=${rule_name_for_delete}
    Run Keyword and Expect Error    *    Get DV Parser    ${rule_name_for_delete}
    
Search DV parser by name
    Run Keyword and Ignore Error    Create DV Parser With Post Data File    testdata/dv/new_dv_parser.json
    Get DV Parser    name=${rule_name_for_delete}

DV parser rule type - Normal reg expression
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_reg.dv
    Create DV Collector and Send Parser Rule Sample Log    test_正则表达式
    ${condition}    Set Variable    (目的地址 = "172.16.19.85" AND 进程命令行 = "ls")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0
    
DV parser rule type - Grok reg expression
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_grok.dv
    Create DV Collector and Send Parser Rule Sample Log    test_Grok正则
    ${condition}    Set Variable    (目的地址 = "55.3.244.1" AND 目的端口 = 15824)
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0
    
DV parser rule type - Delimiter
    [Tags]    dataviewer
    Run Keyword And Ignore Error    Delete DV Parser    name=test_分隔符
    Import DV Parse Rule File    testdata/dv/dv_parser_type_delimit.dv
    Create DV Collector and Send Parser Rule Sample Log    test_分隔符
    ${condition}    Set Variable    (目的地址 = "1.1.1.1" AND 源地址 = "2.3.4.5" AND 进程命令行 = "ls")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - Key and value
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_key_value.dv
    Create DV Collector and Send Parser Rule Sample Log    test_键值对
    ${condition}    Set Variable    (目的地址 = "1.1.22.33" AND 源地址 = "8.8.8.8" AND 目的端口 = 456)
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - CEF
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_cef.dv
    Create DV Collector and Send Parser Rule Sample Log    	test_CEF
    ${condition}    Set Variable    (源地址 = "10.8.75.207" AND 附件数量 = 6 AND 网址 = "aus4-admin.mozilla.org")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - XML
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_xml.dv
    Create DV Collector and Send Parser Rule Sample Log    test_XML
    ${condition}    Set Variable    (目的地址 = "8.8.8.8" AND 源端口 = 7 AND 邮件主题 = "100MB")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - JSON
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_json.dv
    Create DV Collector and Send Parser Rule Sample Log    test_JSON
    ${condition}    Set Variable    (邮件客户端 = "aaa" AND 进程命令行 = "ssss" AND 用户账号 = "admin")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - Script
    [Tags]    no_dv
    Import DV Parse Rule File    testdata/dv/dv_parser_type_script.dv
    Create DV Collector and Send Parser Rule Sample Log    test_脚本
    ${condition}    Set Variable    (解析规则名称 = "test_脚本")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule type - No parsing
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_no_parsing.dv
    Create DV Collector and Send Parser Rule Sample Log    test_不解析
    ${condition}    Set Variable    (解析规则名称 = "test_不解析")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Add field
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_add_field.dv
    Create DV Collector and Send Parser Rule Sample Log    test_添加字段
    ${condition}    Set Variable    (邮件主题 = "test_add")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Delete field
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_delete_field.dv
    Create DV Collector and Send Parser Rule Sample Log    test_删除字段
    ${condition}    Set Variable    (解析规则名称 = "test_删除字段")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Rename field
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_rename_field.dv
    Create DV Collector and Send Parser Rule Sample Log    test_字段重命名
    ${condition}    Set Variable    (邮件主题 = "test_rename")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Merge field
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_merge_field.dv
    Create DV Collector and Send Parser Rule Sample Log    test_合并字段
    ${condition}    Set Variable    (邮件主题 = "test_merge")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Cut field
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_cut_field.dv
    Create DV Collector and Send Parser Rule Sample Log    test_裁剪字段
    ${condition}    Set Variable    (邮件主题 = "test_cut")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Full match and parse
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_full_match.dv
    Create DV Collector and Send Parser Rule Sample Log    test_数据匹配再解析
    ${condition}    Set Variable    (邮件主题 = "test_full_match")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Head match and parse
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_head_match.dv
    Create DV Collector and Send Parser Rule Sample Log    test_数据头匹配再解析
    ${condition}    Set Variable    (邮件主题 = "test_head_match")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Tail match and parse
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_tail_match.dv
    Create DV Collector and Send Parser Rule Sample Log    test_数据尾匹配再解析
    ${condition}    Set Variable    (邮件主题 = "test_tail_match")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Reg match and parse
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_reg_match.dv
    Create DV Collector and Send Parser Rule Sample Log    test_数据正则匹配再解析
    ${condition}    Set Variable    (邮件主题 = "test_reg_match")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Contain match and parse
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_contain_match.dv
    Create DV Collector and Send Parser Rule Sample Log    test_数据包含再解析
    ${condition}    Set Variable    (邮件主题 = "test_contain_match")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Parse field again
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_parse_again.dv
    Create DV Collector and Send Parser Rule Sample Log    test_字段再解析
    ${condition}    Set Variable    (邮件主题 = "test_add" AND 解析规则名称 = "test_字段再解析")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Delete whole log
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_filter_delete_log.dv
    Create DV Collector with Parser Rules    test_删除整条数据
    ${log}    Generate Random Name    delete
    Send Data    ${log}
    Sleep    3
    Module Exec    Elasticsearch    flush_es_event_index
    ${filter_condition_a}    Generate Filter Base Condition    original_log    =    ${log}
    ${condition}    Set Variable    (原始日志 = "${log}")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Be Equal As Integers    ${cnt}    0
    ${log}    Generate Random Name    test
    Send Data    ${log}
    Sleep    3
    Module Exec    Elasticsearch    flush_es_event_index
    ${filter_condition_a}    Generate Filter Base Condition    original_log    =    ${log}
    ${condition}    Set Variable    (原始日志 = "${log}")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Datetime mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_datetime.dv
    Create DV Collector and Send Parser Rule Sample Log    test_时间映射
    ${condition}    Set Variable    (登录时间 = "1520647345000")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Text mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_text.dv
    Create DV Collector and Send Parser Rule Sample Log    test_文本映射
    ${condition}    Set Variable    (邮件主题 = "after")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Reg mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_reg.dv
    Create DV Collector and Send Parser Rule Sample Log    test_正则映射
    ${condition}    Set Variable    (邮件主题 = "reg")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Base64 mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_base64.dv
    Create DV Collector and Send Parser Rule Sample Log    test_Base64映射
    ${condition}    Set Variable    (邮件主题 = "4.4.4.4")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - URL mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Create DV Collector and Send Parser Rule Sample Log    test_URL映射
    ${condition}    Set Variable    (邮件主题 = "http://www.a.a")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - Redefine mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_redefine.dv
    Create DV Collector and Send Parser Rule Sample Log    test_重定义映射
    ${condition}    Set Variable    (源地址 = "172.16.100.107")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter type - IP convert mapping
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_ip.dv
    Create DV Collector and Send Parser Rule Sample Log    test_IP解码映射
    ${condition}    Set Variable    (源地址 = "222.190.251.173" AND 目的地址 = "2404:3600:0:1:0:0:0:1")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

DV parser rule data filter with multiple filter Condition
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_mappin_multiple_condition.dv
    Create DV Collector and Send Parser Rule Sample Log    test_多映射匹配
    ${condition}    Set Variable    (邮件主题 = "映射值one")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0
    Send Data    2
    Sleep    3
    Module Exec    Elasticsearch    flush_es_event_index
    ${condition}    Set Variable    (邮件主题 = "映射值two")
    ${cnt}    Query Event Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Export some DV parser rules
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_no_parsing.dv
    @{rule_list}    Create List     ${default_builtin_rule_name}    ${export_import_rule_for_test}
    Export DV Parse Rule File    local_file=${eport_import_rule_file}    rule_name=${rule_list}
    
Import DV parser rules
    [Tags]    dataviewer
    Delete DV Parser    name=${export_import_rule_for_test}
    Import DV Parse Rule File    ${eport_import_rule_file}
    Remove File    ${eport_import_rule_file}
    Get DV Parser    ${export_import_rule_for_test}

It cannt delete parser rule used by DV source
    [Tags]    dataviewer
    Import DV Parse Rule File    testdata/dv/dv_parser_type_no_parsing.dv
    Create DV Collector and Send Parser Rule Sample Log    test_不解析
    Run Keyword and Expect Error    *    Delete DV Parser    name=test_不解析

Stop DV collector
    [Tags]    dataviewer
    Log    covered in previous cases steps
    
Start DV collector
    [Tags]    dataviewer
    Log    covered in previous cases steps
    
Delete DV collector
    [Tags]    dataviewer
    Log    covered in previous cases steps

Create one DV collector - KAFKA
    [Tags]    dataviewer
    Stop and Delete All DV Source
    ${rule_list}    Create List
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Append To List    ${rule_list}    ${kafka_db_file_source_test}
    ${source_name}    Create DV Kafka Source    resolver=${rule_list}
    Start DV Source    ${source_name}

Create one DV collector - File
    [Tags]    dataviewer
    Stop and Delete All DV Source
    ${rule_list}    Create List
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Append To List    ${rule_list}    ${kafka_db_file_source_test}
    ${path}=    Set Variable    /opt/test.txt
    Execute SSH Cmd    echo 1234 > ${path}
    ${source_name}    Create DV File Source    resolver=${rule_list}    file=${path}
    Start DV Source    ${source_name}

Create one DV collector - DB
    [Tags]    dataviewer
    Stop and Delete All DV Source
    ${rule_list}    Create List
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Append To List    ${rule_list}    ${kafka_db_file_source_test}
    ${source_name}    Create DV Self DB Source    resolver=${rule_list}
    Start DV Source    ${source_name}

Create one DV collector - SFTP
    [Tags]    dataviewer
    Stop and Delete All DV Source
    ${rule_list}    Create List
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Append To List    ${rule_list}    ${kafka_db_file_source_test}
    ${path}=    Set Variable    /opt/test.txt
    Execute SSH Cmd    echo 1234 > ${path}
    ${source_name}    Create DV Self SFTP Source    resolver=${rule_list}    file=${path}
    Start DV Source    ${source_name}

Search DV source
    [Tags]    dataviewer
    Run Keyword and Expect Error    *    Search DV Source By Name    name=not_exist
    ${rule_list}    Create List
    Import DV Parse Rule File    testdata/dv/dv_parser_mapping_url.dv
    Append To List    ${rule_list}    ${kafka_db_file_source_test}
    ${source_name}    Create DV Self DB Source    resolver=${rule_list}
    Search DV Source By Name    name=${source_name}

Create one DV store - KAFAKA
    [Tags]    dataviewer
    ${name}    Generate Random Name    dv_store_kafka_
    Create Kafka DV Store    name=${name}    address=${local_ip}
    Search DV Store By Name    name=${name}
    
Create one DV store - ES
    [Tags]    dataviewer
    ${name}    Generate Random Name    dv_store_es_
    Create ES DV Store    name=${name}    address=${local_ip}
    Search DV Store By Name    name=${name}

Create one DV store - Net
    [Tags]    dataviewer
    ${name}    Generate Random Name    dv_store_net_
    Create Net DV Store    name=${name}    address=${local_ip}
    Search DV Store By Name    name=${name}

Create dupplicated name of DV store
    [Tags]    dataviewer
    ${name}    Generate Random Name    dv_store_duplicate_
    Create ES DV Store    name=${name}    address=${local_ip}
    Run Keyword and Expect Error    *    Create ES DV Store    name=${name}    address=${local_ip}

Search DV store
    [Tags]    dataviewer
    Run Keyword and Expect Error    *    Search DV Store By Name    name=not_exist
    Search DV Store By Name    name=${default_es_store_name}

Delete one DV store
    [Tags]    dataviewer
    ${name}    Generate Random Name    test_delete_store_
    Create ES DV Store    name=${name}    address=${local_ip}
    Delete DV Store    name=${name}
    Run Keyword and Expect Error    *    Search DV Store By Name    name=${name}

It can not delete dv store used by DV source
    Run Keyword and Expect Error    *    name=${default_es_store_name}


*** Keywords ***
TestSetup
    User Login    ${default_username}    ${default_password}

TestTeardown
    Run Keyword And Ignore Error    Delete DV Parser    name=${rule_name_for_delete}
    User Logout

Create DV Collector and Send Parser Rule Sample Log
    [Arguments]    ${parser_rule_name}
    ${rule}    Get DV Parser    ${parser_rule_name}
    Create DV Collector with Parser Rules    ${parser_rule_name}
    Send Data    ${rule["sample"]}
    Sleep    2
    Module Exec    Elasticsearch    flush_es_event_index
    Sleep    1

Quey Event Logs with Condition
    [Arguments]    ${filter_condition_list}
    ${module}    Set Variable    Event
    ${start_time}    Get Current Date    result_format=%Y-%m-%d
    ${end_time}    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    ${filter_expression}    Generate Filter Condition
    ...    AND    ${filter_condition_list}
    ${len}    Query Data    module=${module}    start_time=${start_time}    end_time=${end_time}    filter_expression=${filter_expression}
    [Return]    ${len}