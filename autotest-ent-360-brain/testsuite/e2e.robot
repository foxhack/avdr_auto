*** Settings ***
Documentation     E2E Test for Hansight Enterprise
Suite Setup       E2E Suite Setup
Suite Teardown    E2E Suite Teardown
Test Setup        Case Setup Default User Login
Library           DateTime
Resource          kw_ent.robot
Resource          kw_sys_cfg.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_event.robot
Resource          kw_asset.robot
Resource          kw_cep.robot
Resource          kw_report.robot
Resource          kw_dataviewer.robot
Resource          kw_utils.robot
Resource          kw_notify.robot
Resource          kw_vulnerability.robot
Resource          kw_alarm.robot
Resource          kw_ldap_user.robot
Resource          kw_history_task.robot
Resource          kw_ti.robot

*** Variables ***
${e2e_default_intranet}    内网
${e2e_default_event_parser_name}    AP_锐捷_通用_1
${e2e_default_cep_rule_name}    SQL注入后发生数据库提权
${e2e_cep_rule_alarm_type}    /networksec
${e2e_cep_rule_alarm_stage}    1
${e2e_cep_rule_alarm_level}    0
${e2e_cep_rule_type}    访问异常
${e2e_cep_rule_template}    普通模板
${e2e_cep_rule_tested}    通用web攻击
${e2e_cep_ti_rule}    cep-ti
${e2e_event_parser_content}    event_parser_test
${e2e_event_parser_regex}    .+parser.+
${e2e_event_tpye}    授权管理
${e2e_alarm_send_count}    ${1}
${e2e_event_send_count}    ${2}
${e2e_default_dv_worker}    worker-001
${e2e_asset_import_name}    asset_import
${e2e_asset_import_ip}    1.1.1.1
${e2e_ti_related_ip}    8.8.8.8

*** Test Cases ***
Active With License
    [Setup]
    Run Keyword And Ignore Error    User Login    ${default_username}    ${default_password}
    ${msg}=    Run Keyword and Expect Error    *    Import License    testdata/license/invalid_license.lic
    Should Contain    ${msg}    当前许可证不可用！
    Import License    testdata/license/valid_license.lic

System Init Config
    Run Keyword And Ignore Error    Execute Mysql Cmd    UPDATE sae_rule_type SET id = 10015 WHERE id = 10045
    Sleep    10
    Init System Import Module    testdata/init/export_5.0_test_rule.zip

Login With Default Account
    [Setup]
    ${invalid_password}    Set Variable    111111
    ${msg}=    Run Keyword and Expect Error    *    User Login    ${default_username}    ${invalid_password}
    User Login    ${default_username}    ${default_password}

Login With New Created Account
    ${menu}    Create List
    Run Keyword and Expect Error    *    Add Role    menu=${menu}
    ${menu_item}    Generate Menu Dict    ${allow_menu}    ${allow_type}
    Append To List    ${menu}    ${menu_item}
    ${menu_name}    Add Role    menu=${menu}
    ${menu_info}    Get Role    ${menu_name}
    ${menu_id}    Set Variable    ${menu_info['id']}
    ${roles}    Create List
    Run Keyword and Expect Error    *    Add User    password=${suggest_password}    roles=${roles}
    Append To List    ${roles}    ${menu_name}
    ${user_name}    Add User    password=${suggest_password}    roles=${roles}
    ${user_info}    Get User    ${user_name}
    ${user_id}    Set Variable    ${user_info['id']}
    User Logout
    user login    ${user_name}    ${suggest_password}
    [Teardown]    Case Teardown Delete New Created Account    ${user_id}    ${menu_id}

Intranet Network Location
    ${intranet_name}    Set Variable    ${e2e_default_intranet}
    ${intranet_id}    Get_Intranet_ID    ${intranet_name}
    Update Intranet    ${intranet_id}

Email Config
    ${host}    Set Variable    smtp.163.com
    ${port}    Set Variable    25
    ${username}    Set Variable    hansight_test@163.com
    ${password}    Set Variable    hansight1234
    Update_SMTP    host=${host}    port=${port}    username=${username}    password=${password}

Notify Config
    ${random_phoneNumbers}    Generate Random String    8    0123456789
    ${phoneNumbers}    Set Variable    182${random_phoneNumbers},182${random_phoneNumbers}
    ${smtp_data}    Get SMTP
    ${emails}    Set Variable    ${smtp_data['data']['username']}
    ${name1}    Create Notify    smsEnabled=${1}    phoneNumbers=${phoneNumbers}
    ${name2}    Create Notify    mailEnabled=${1}    emails=${emails}
    ${name3}    Create Notify    cmdEnabled=${1}    cmd=sms.sh
    ${defualt id}    Get Default Notify
    Update Notify    id=${defualt id}    mailEnabled=${1}    emails=${emails}    smsEnabled=${1}    phoneNumbers=${phoneNumbers}    cmdEnabled=${1}
    ...    cmd=sms.sh
    ${notify_list}    List Notify
    Should Not Be Empty    ${notify_list}

Create New DV Collector
    [Tags]    dataviewer
    Create DV Collector For Test

Query Event and Alarm Data
    [Tags]    e2e
    Init System Import Module    testdata/init/export_5.0_test_rule.zip
    Sleep    5
    Create DV Collector with Parser Rules    测试规则-勿删除
    ${content1}    Set Variable    5,1.1.1.1,500,2.2.2.2,600,3
    ${content2}    Set Variable    4,1.1.1.11,100,2.2.2.12,300,4
    Send Data    ${content1}    ${e2e_event_send_count}
    Send Data    ${content2}
    Sleep    30
    Module Exec    Elasticsearch    flush_es_event_index
    ${cnt}    Query Event Logs Count
    Should Not Be Equal As Integers    ${cnt}    ${0}
    ${cnt}    Query Alarm Logs Count
    Should Not Be Equal As Integers    ${cnt}    ${0}

Get DV Worker Status
    [Tags]    dataviewer
    ${status}    Get DV Collector Status    ${e2e_default_dv_worker}
    should be equal    ${status}    RUNNING

Create DV Rule With Default Name
    [Tags]    dataviewer
    Run Keyword And Ignore Error    Create DV Parser With File    testdata/dv/buildin_parser.json
    ${name}    Set Variable    ${e2e_default_event_parser_name}
    Run Keyword And Expect Error    *    Create DV Parser With File    testdata/dv/buildin_parser.json    ${name}

Create New DV Rule
    [Tags]    dataviewer
    ${name}    Generate Random Name    dv_rule_
    Run Keyword And Expect Error    *    Create DV Parser With File    testdata/dv/new_parser.json    ${name}

Create CEP Rule With Default Name
    Run Keyword And Ignore Error    Import CEP Rule    testdata/ceprule/buildin_cep_rule
    ${name}    Set Variable    ${e2e_default_cep_rule_name}
    ${b_enabled}    Set Variable    ${True}
    ${alarm_type}    Set Variable    ${e2e_cep_rule_alarm_type}
    ${alarm_stage}    Set Variable    ${e2e_cep_rule_alarm_stage}
    ${alarm_level}    Set Variable    ${e2e_cep_rule_alarm_level}
    ${alarm_content}    Set Variable    warning
    ${alert}    Generate Alert Dict    b_enabled=${b_enabled}    alarm_type=${alarm_type}    alarm_stage=${alarm_stage}    alarm_level=${alarm_level}    alarm_content=${alarm_content}
    ${type_name}    Set Variable    ${e2e_cep_rule_type}
    ${template_name}    Set Variable    ${e2e_cep_rule_template}
    ${desc}    Set Variable    test cep rule
    ${status}    Set Variable    ${1}
    Run Keyword and Expect Error    *    Create CEP Rule    name=${name}    type_name=${type_name}    template_name=${template_name}    alert=${alert}
    ...    desc=${desc}    status=${status}

Daily Report
    [Tags]    
    ${template_id}    Add New Test Report Template    ${report_temp_buildin}
    ${templates}    Create List
    Append To List    ${templates}    ${template_id}
    ${report_name}    Add Time Report    templates=${templates}
    Log    create\ daily\ time\ report\ ${report_name}
    ${report_info}    Get Time Report    ${report_name}
    ${report_id}    Set Variable    ${report_info['id']}
    Retrive Time Report    ${report_id}
    Delete Report Template    ${template_id}

Immediate Report
    [Tags]    
    ${template_id}    Add New Test Report Template    ${report_temp_buildin}
    ${templates}    Create List
    Append To List    ${templates}    ${template_id}
    ${report_name}    Add Time Report    frequency=${0}    templates=${templates}
    Sleep    5
    ${report_info}    Get Time Report    ${report_name}
    ${report_id}    Set Variable    ${report_info['id']}
    Sleep    3
    Run Time Report    ${report_id}
    Sleep    5
    ${result}=    Wait Until Keyword Succeeds    ${30}    ${3}    Check Report    ${report_id}    ${template_id}
    Delete Report Template    ${template_id}
    Should Not Be Empty    ${result}
    Should Contain    ${result}    xlsx

Dynamical Report
    Init System Import Module    testdata/init/export_report.zip
    Sleep    10
    ${template}=    Get Report Template    安全综合报告
    ${templates}    Create List
    Append To List    ${templates}    ${template['id']}
    ${report_name}    Add Time Report    frequency=${0}    templates=${templates}
    Sleep    5
    ${report_info}    Get Time Report    ${report_name}
    ${report_id}    Set Variable    ${report_info['id']}
    Run Time Report    ${report_id}
    Sleep    5
    ${result}=    Wait Until Keyword Succeeds    ${60}    ${3}    Check Report    ${report_id}    ${template['id']}
    Should Not Be Empty    ${result}

SecurityPolicy Config
    Update SecurityPolicy    pwdMin=${9}    pwdUppercase=${true}    attemptLoginUnlock=${false}    passwordExpirationEnabled=${true}    passwordExpiration=${50}
    ${data}    Get SecurityPolicy
    Should Be Equal    ${data['pwdMin']}    ${9}
    Should Be Equal    ${data['pwdUppercase']}    ${true}
    Should Be Equal    ${data['attemptLoginUnlock']}    ${false}
    Should Be Equal    ${data['passwordExpirationEnabled']}    ${true}
    Should Be Equal    ${data['passwordExpiration']}    ${50}

LDAP Config
    Config Official LDAP Server
    ${user_list}    Get All User
    Should Not Be Empty    ${user_list}

Mantainance Config
    ${config_info}    Get Mantainance
    Update Mantainance    isValid=${true}    firstThreshold=${50}    secondThreshold=${70}    retainDay=${20}
    ${config_info}    Get Mantainance
    Should Be Equal    ${config_info['isValid']}    ${true}
    Should Be Equal    ${config_info['firstThreshold']}    ${50}
    Should Be Equal    ${config_info['secondThreshold']}    ${70}
    Should Be Equal    ${config_info['retainDay']}    ${20}

Check Storage Days By Index
    ${keep_days}    Set Variable    3
    ${end}=    Get Current Date
    ${end}=    Convert Date    ${end}    exclude_millis=yes
    ${start}=    Subtract Time From Date    ${end}    7 days
    ${start}=    Convert Date    ${start}    exclude_millis=yes
    @{date_range}=    Get Date Range    ${start}    ${end}
    Import DV Parse Rule File    testdata/dv/dv_parser_datetime_range.dv
    Create DV Collector with Parser Rules    测试搜索告警规则-勿删除
    :FOR    ${item}    IN    @{date_range}
    \    Send Data    4,1.1.1.11,100,2.2.2.12,300,4,${item}
    Sleep    10
    Module Exec    Elasticsearch    flush_es_event_index
    Config Index Storage Days    event_$    ${keep_days}
    Update Mantainance    isValid=${true}    firstThreshold=${50}    secondThreshold=${90}    retainDay=${20}
    Sleep    5
    ${check_days_cmd}=    Set Variable    curl http://127.0.0.1:9200/_cat/indices?h=index | grep event | grep -v error | wc -l
    ${days}=    Execute SSH Cmd    ${check_days_cmd}
    ${expected}=    Evaluate    ${days} - 1
    Should Be Equal As Integers    ${expected}    ${keep_days}

Check CDT
    ${result}    Run CDT
    Should Contain    ${result}    diagnose_package

Data Role
    ${ip_role}    Set Variable    1.2.3.4
    ${ip_no_role}    Set Variable    1.1.1.1
    ${data_roles}    Create List
    ${roles}    Create List
    ${role_info}    Add Data Role    type=ip    content=single:${ip_role}
    Append To List    ${data_roles}    ${role_info[1]}
    Append To List    ${roles}    系统管理员
    ${user_name}    Add User    password=${suggest_password}    roles=${roles}    data_roles=${data_roles}
    Init System Import Module    testdata/init/export_5.0_test_rule.zip
    Sleep    5
    Create DV Collector with Parser Rules    测试规则-勿删除
    ${content}    Set Variable    5,${ip_role},500,2.2.2.2,600,3
    Send Data    ${content}    ${e2e_event_send_count}
    ${content}    Set Variable    5,${ip_no_role},500,2.2.2.2,600,3
    Send Data    ${content}    ${e2e_event_send_count}
    Sleep    20
    Module Exec    Elasticsearch    flush_es_event_index
    User Logout
    User Login    ${user_name}    ${suggest_password}
    ${condition1}    Set Variable    (源地址 = "${ip_no_role}")
    ${condition2}    Set Variable    (源地址 = "${ip_role}")
    ${cnt_event}    Query Event Logs Count    Condition=${condition1}
    ${cnt_alarm}    Query Alarm Logs Count    Condition=${condition1}
    Should Be Equal As Integers    ${cnt_event}    0
    Should Be Equal As Integers    ${cnt_alarm}    0
    ${cnt_event}    Query Event Logs Count    Condition=${condition2}
    ${cnt_alarm}    Query Alarm Logs Count    Condition=${condition2}
    Should Not Be Equal As Integers    ${cnt_event}    0
    Should Not Be Equal As Integers    ${cnt_alarm}    0

Check Debug Page Access
    Get Debug Page    __proxy/es-head
    Get Debug Page    __proxy/es-sql
    Get Debug Page    __proxy/es-cerebro
    Get Debug Page    __proxy/ice-debug/debug.html

*** Keywords ***
E2E Suite Setup
    No Operation

E2E Suite Teardown
    No Operation

Case Teardown Delete New Created Account
    [Arguments]    ${user_id}    ${menu_id}=${EMPTY}
    User Logout
    User Login    ${default_username}    ${default_password}
    Delete User    ${user_id}
    Run Keyword If    '${menu_id}'!='${EMPTY}'    Delete Role    id=${menu_id}

Case Setup Default User Login
    User Login    ${default_username}    ${default_password}

Event And Alarm rule Preparation
    Run Keyword And Ignore Error    Import EventParser    testdata/eventparser/buildin_event_parser
    Run Keyword And Ignore Error    Import EventParser    testdata/eventparser/WAF_LM_1    strategy=overwrite
    Run Keyword And Ignore Error    Import EventParser    testdata/eventparser/WAF_LM_2    strategy=overwrite
    Run Keyword And Ignore Error    Import CEP Rule    testdata/ceprule/buildin_cep_rule
    Run Keyword And Ignore Error    Import CEP Rule    testdata/ceprule/buildin_cep    strategy=overwrite

For Vul Detail
    [Arguments]    ${ip}    ${name}    ${type}
    ${vul_detail}    Get Vul Detail    ip=${ip}    name=${name}    type=${type}
    : FOR    ${j}    IN    ${vul_detail}
    \    Should Be Equal    ${j[0]['ip']}    ${ip}
    \    Should Be Equal    ${j[0]['name']}    ${name}
    \    Should Be Equal    ${j[0]['type']}    ${type}

Create DV Collector For Test
    Import DV Parse Rule File    testdata/dv/WAF_lv_tong_1.dv
    Import DV Parse Rule File    testdata/dv/WAF_lv_tong_2.dv
    Import DV Parse Rule File    testdata/dv/SecAudit_shenxinfu_AC_3.dv
    Create DV Collector with Parser Rules    WAF_绿盟_通用_1    WAF_绿盟_通用_2    安全审计_深信服_AC_3