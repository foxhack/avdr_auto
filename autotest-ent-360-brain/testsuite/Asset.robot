*** Settings ***
Documentation     Test for Asset Management
Test Setup        TestSetup
Test Teardown     TestTeardown
Resource          ../keywords/kw_ent.robot
Resource          ../keywords/kw_sys_cfg.robot
Resource          ../keywords/kw_dataviewer.robot
Resource          ../keywords/kw_asset.robot
Resource          ../keywords/kw_vulnerability.robot

*** Variables ***
${new_asset_ip}    172.16.100.99
${new_asset_type}    Test-type
${new_asset_bussines}    Test-bussines
${new_asset_security_domain}    Test-domain
${new_asset_location}    Test-location
${imported_asset_file}    testdata/asset/imported_asset.xlsx

*** Test Cases ***
Add and delete one asset type
    ${type}=    Add asset type    name=${new_asset_type}
    Get asset type by ID    id=${type[0]}
    Delete asset type    id=${type[0]}
    Run Keyword and Expect Error    *    Get asset type by ID    id=${type[0]}

Add and delete one asset bussines
    ${business}=    Add business    name=${new_asset_bussines}
    Get Business By ID    id=${business[0]}
    Delete business    id=${business[0]}
    Run Keyword and Expect Error    *    Get Business By ID    id=${business[0]}

Add and delete one asset security domain
    ${domain}=    Add security domain    name=${new_asset_security_domain}
    Get security domain by ID    id=${domain[0]}
    Delete security domain    id=${domain[0]}
    Run Keyword and Expect Error    *    Get security domain by ID    id=${domain[0]}

Add and delete one asset location
    ${location}=    Add location    name=${new_asset_location}
    Get location by ID    id=${location[0]}
    Delete location    id=${location[0]}
    Run Keyword and Expect Error    *    Get location by ID    id=${location[0]}

Search asset by Name/IP/Owner
    ${asset1}=    Add Asset    asset_name=ftp_server    ip_address=192.168.1.1
    ${asset2}=    Add Asset    asset_name=lab_pc    ip_address=192.168.1.2
    ${asset2}=    Add Asset    asset_owner=Tom    ip_address=192.168.1.3
    ${data}=    Search asset by filter    type=asset_name    filter=ftp
    Length Should Be    ${data}    1
    Should Be Equal As Strings    ${data[0]['ip_address']}    192.168.1.1
    ${data}=    Search asset by filter    type=general_ip    filter=192.168.1.2
    Length Should Be    ${data}    1
    Should Be Equal As Strings    ${data[0]['asset_name']}    lab_pc
    ${data}=    Search asset by filter    type=responsible_id    filter=Tom
    Length Should Be    ${data}    1
    Should Be Equal As Strings    ${data[0]['ip_address']}    192.168.1.3

Search asset by Tag
    Add custom tags    test
    Add Asset    ip_address=${new_asset_ip}
    ${data}=    Search asset by tags    tags=test
    Length Should Be    ${data}    1
    ${data}=    Search asset by tags    tags=test1
    Length Should Be    ${data}    0

Asset Score
    Run Keyword And Ignore Error    Add business    name=AAAA
    Run Keyword And Ignore Error    Add business    name=BBBB
    Run Keyword And Ignore Error    Add business    name=CCCC
    Run Keyword And Ignore Error    Add Asset    asset_name=AAAA    ip_address=${new_asset_ip}    business_name=AAAA
    Run Keyword And Ignore Error    Add Asset    asset_name=BBBB    ip_address=172.16.200.1    business_name=BBBB
    Run Keyword And Ignore Error    Add Asset    asset_name=CCCC    ip_address=172.16.200.2    business_name=CCCC
    Import Vulnerability Info    ip=${new_asset_ip}
    Import Vulnerability Info    ip=172.16.200.1
    Import Vulnerability Info    ip=172.16.200.2
    Init System Import Module    testdata/init/export_5.0_test_rule.zip
    Sleep    5
    Create DV Collector with Parser Rules    测试规则-勿删除
    ${content}=    Set Variable    2,1.1.1.1,500,${new_asset_ip},600,3
    ${content2}=    Set Variable    6,1.1.1.11,500,172.16.200.1,600,3
    ${content3}=    Set Variable    7,1.1.1.21,500,172.16.200.2,600,3
    Send Data    ${content}
    Send Data    ${content2}
    Send Data    ${content3}
    Sleep    15
    Trigger Asset Score
    Wait Until Asset Score
    ${data}=    Get Asset View Score
    Should Not Be Equal As Integers    ${data['risk_score']}    0
    ${data}=    Get Asset View Score    scope=1    keyword=${new_asset_ip}
    Should Not Be Equal As Integers    ${data['risk_score']}    0
    ${data}=    Get Risk Asset By Business
    Length Should Be    ${data}    3

*** Keywords ***
TestSetup
    User Login    ${default_username}    ${default_password}
    Delete All Asset

TestTeardown
    User Logout

Trigger Asset Score
    ${sql}=    Set Variable    update JOB_DATA set JOB_CRON_EXPRESSION='*/5 * * * * ?' where JOB_ID=2
    Execute Mysql Cmd    ${sql}
    Sleep    20
    ${sql}=    Set Variable    update JOB_DATA set JOB_CRON_EXPRESSION='0 0 2 * * ?' where JOB_ID=2
    Execute Mysql Cmd    ${sql}

Wait Until Asset Score
    Wait Until Keyword Succeeds    120    5    Asset Score is Not Empty
