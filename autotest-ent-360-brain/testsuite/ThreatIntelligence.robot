*** Settings ***
Documentation     Test for Hansight Enterprise
Suite Setup       TI Suit Setup
Test Setup        Test Setup
Test Teardown     Test Teardown
Library           OperatingSystem
Resource          kw_ent.robot
Resource          kw_alarm.robot
Resource          kw_whitelist.robot
Resource          kw_threat.robot
Resource          kw_utils.robot
Resource          kw_dataviewer.robot
Resource          kw_sys_cfg.robot
Resource          kw_vulnerability.robot

*** Variables ***
${module_id_ti}    1fd1d830-ab6d-449a-84fc-144331c124d7
${saerule_match}    SAE Match
${saerule_IP}     Belong 内网IP
${saerule_digit}    Belong digit information
${saerule_time}    Belong DateTime Information
${saerule_string}    Belong String Information
${saerule_TI_IP}    威胁情报IP匹配
${saerule_TI_Domain}    威胁情报Domain匹配
${url_query}      url: true
${hash_query}     hash: true
${event_tiquery_cnt}    7
${restart_keyword}    Started IncidentApplication in
${content1}       src:172.16.100.100,dst:1.1.1.1,domain:www.bing.com,hash_file:54e1c3722102182bb133912ad4442e19,url:http://landini.az/greeting-ecards
${content2}       src:207.148.70.143,dst:8.8.8.8,domain:eth.uupool.cn,hash_file:5e1c3722102182bb133912ad4442e19,url:http://landini.az/greeting-ecards
${license_path}    testdata/license/valid_license.lic
${export_global_whitelist_file}    export_global_whitelist.xlsx
${export_intelligence_whitelist_file}    export_local_intelligence_whitelist.xlsx
${file_path}      testdata/whitelist/intelligence_whitelist_cn.xlsx
${global_file}    testdata/whitelist/global_whitelist_cn.xlsx
${dv_test_rule_file}    testdata/dv/parser_hash_cnn.txt
${sae_rule_init_package}    testdata/init/export_5.0_test_rule.zip
${dv_parser_rule_name}    test hash and url
${saerule_Vul}    漏洞利用关联告警
${content3}       src:182.16.100.100,dst:172.16.200.2,domain:www.bing.com,hash_file:54e1c3722102182bb133912ad4442e19,url:http://landini.az/greeting-ecards,cve:CVE-2012-3439


*** Test Cases ***
Update ICE config to Query TI
    Execute SSH Cmd    > /opt/hansight/enterprise/incident/logs/incident.log
    ${cmd1}    set variable    sed -i "s/hash: false/hash: true/g" /opt/hansight/enterprise/incident/application.yml    #modify the configuration about ti query on line
    ${cmd2}    set variable    sed -i "s/url: false/url: true/g" /opt/hansight/enterprise/incident/application.yml
    ${cmd3}    set variable    sed -i "192s/10000/7/g" /opt/hansight/enterprise/incident/application.yml
    ${cmd4}    set variable    sed -i "199s/1000/5/g" /opt/hansight/enterprise/incident/application.yml
    # ${cmd5}    set variable    sed -i "s/forced: 1h/forced: 1m/g" /opt/hansight/enterprise/incident/application.yml
    Execute SSH Cmd    ${cmd1}
    Execute SSH Cmd    ${cmd2}
    Execute SSH Cmd    ${cmd3}
    Execute SSH Cmd    ${cmd4}
    # Execute SSH Cmd    ${cmd5}
    Execute SSH Cmd    /opt/hansight/enterprise/hanctl restart incident    #restart incident
    Wait Until Keyword Succeeds    3min    5s    Check ICE Restart Succuss

Alert-IP check with Sending syslog
    Send Data    ${content1}
    sleep    30
    ${condition}    Set Variable    (目的地址 = "1.1.1.1" AND 告警名称 = "${saerule_IP}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert-Digit check with Sending syslog
    Send Data    ${content1}
    sleep    10
    ${condition}    Set Variable    (目的地址 = "1.1.1.1" AND 告警名称 = "${saerule_digit}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert-DateTime check with Sending syslog
    Send Data    ${content1}
    sleep    10
    ${condition}    Set Variable    (目的地址 = "1.1.1.1" AND 告警名称 = "${saerule_time}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert-String check with Sending syslog
    Send Data    ${content2}
    sleep    10
    ${condition}    Set Variable    (目的地址 = "8.8.8.8" AND 告警名称 = "${saerule_string}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert SAE-Match check with Sending syslog
    ${ioc_ip}    Set Variable    64.227.122.45
    ${new_content}    Regex Syslog Src_IP    ${content2}    src:${ioc_ip}
    Send Data    ${new_content}
    sleep    20
    ${condition}    Set Variable    (源地址 = "${ioc_ip}" AND 告警名称 = "${saerule_match}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert TI-IP check with Sending syslog
    ${ioc_ip}    Set Variable    64.227.122.45
    ${new_content}    Regex Syslog Src_IP    ${content2}    src:${ioc_ip}
    Send Data    ${new_content}
    sleep    10
    ${condition}    Set Variable    (源地址 = "${ioc_ip}" AND 告警名称 = "${saerule_TI_IP}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

Alert TI-Domain check with Sending syslog
    ${ioc_domain}    Set Variable    lzxfzw.cn
    ${new_content}    Regex Syslog Domain    ${content2}    domain:${ioc_domain}
    Send Data    ${new_content}
    sleep    10
    ${condition}    Set Variable    (域名 = "${ioc_domain}" AND 告警名称 = "${saerule_TI_Domain}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0

No Alert with Sending IocWhitelist Syslog
    Delete All Ioc-whitelist
    ${ioc_ip}    Set Variable    167.99.239.8
    &{data}    Create Dictionary    content    ${ioc_ip}    contentType    SINGLE    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    ${new_content}    Regex Syslog Src_IP    ${content2}    src:${ioc_ip}
    Send Data    ${new_content}
    sleep    10
    ${condition}    Set Variable    (源地址 = "${ioc_ip}" AND 告警名称 = "${saerule_TI_IP}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Be Equal As Integers    ${cnt}    0

Alert Vulnerability check with sending syslog
    Import Vulnerability Info    ip=172.16.200.2
    Send Data    ${content3}
    sleep    10
    ${condition}    Set Variable    (目的地址 = "172.16.200.2" AND 告警名称 = "${saerule_Vul}")
    ${cnt}    Query Alarm Logs Count    Condition=${condition}
    Should Not Be Equal As Integers    ${cnt}    0


*** Keywords ***
Test Setup
    User Login    ${default_username}    ${default_password}

Test Teardown
    No Operation
    User Logout

TI Suit Setup
    User Login    ${default_username}    ${default_password}
    Init System Import Module    ${sae_rule_init_package}
    Import DV Parse Rule File    ${dv_test_rule_file}
    Create DV Collector with Parser Rules    ${dv_parser_rule_name}
    Cps Update IOC

Cps Update IOC
    ${sql}=    Set Variable    update JOB_DATA set JOB_CRON_EXPRESSION='*/5 * * * * ?' where JOB_ID=5
    Execute Mysql Cmd    ${sql}
    Sleep    30

Check module file can be updated
    [Arguments]    ${module_id}
    ${sql}=    Set Variable    select count(*) from active_update_audit where module_id='${module_id}'
    ${count}=    Execute Mysql Cmd    ${sql}
    Should Not Be Equal As Integers    ${count}    0

Wait until module package can be updated
    [Arguments]    ${module_id}
    Wait Until Keyword Succeeds    90    5    Check module file can be updated    ${module_id_ti}

Check ICE Restart Succuss
    ${log_restart}=    Execute SSH Cmd    grep Started /opt/hansight/enterprise/incident/logs/incident.log
    should contain    ${log_restart}    matches