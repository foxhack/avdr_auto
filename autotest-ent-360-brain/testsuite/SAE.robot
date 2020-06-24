*** Settings ***
Documentation     SAE Test for Hansight Enterprise
Test Setup        SAE Test Setup
Test Teardown     SAE Test Teardown
Suite Setup       SAE Suite Setup
Resource          kw_ent.robot
Resource          kw_sys_cfg.robot
Resource          kw_cep.robot
Resource          kw_dataviewer.robot

*** Variables ***


*** Test Cases ***
SAE Rule Template - Normal
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-normal")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Follow By
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    Send Data    2,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-follow_by")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Repeat Until
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    Send Data    3,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-repeat_until")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Having Count
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-count")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Having Distinct Count
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-distinct_count")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Having Sum
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-sum")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Not Follow By
    Send Data    1,1.1.1.11,511,21.2.2.2,22,1
    Send Data    4,1.1.1.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-not_follow_by")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Template - Or Follow By
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-or_follow_by")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Filter - String Type
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-filter-String")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Filter - DateTime Type
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-filter-DateTime")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Filter - Number Type
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-filter-Number")
    Wait Until Alarm Logs Generated    ${condition}

SAE Rule Filter - IP Type
    Send Data    1,1.1.11.11,511,21.2.2.2,22,1
    ${condition}    Set Variable    (告警名称 = "test-filter-IP")
    Wait Until Alarm Logs Generated    ${condition}

Create New SAE Task For Analysis
    ${task_name}=    Create SAE Task    test-normal
    Wait Until SAE Task Finished    ${task_name}
    Sleep    60
    ${task}    Get SAE Task    ${task_name}
    ${condition}    Set Variable    (job_id = ${task['id']})
    ${cnt}    Query Alarm Logs Count    ${condition}    history_alarm
    Should Not Be Equal As Integers    ${cnt}    0
    Delete SAE Task    ${task['id']}
    Run Keyword and Expect Error    *    Get SAE Task    ${task_name}


*** Keywords ***
SAE Test Setup
    User Login    ${default_username}    ${default_password}

SAE Test Teardown
    No Operation

SAE Suite Setup
    User Login    ${default_username}    ${default_password}
    Init System Import Module    testdata/cep/test_sae_rule_full.zip
    Create DV Collector with Parser Rules    测试规则-勿删除

Alarm Logs Should Be Not Empty
    [Arguments]    ${search_condition}
    ${cnt}    Query Alarm Logs Count    Condition=${search_condition}
    Should Not Be Equal As Integers    ${cnt}    0

Wait Until Alarm Logs Generated
    [Arguments]    ${search_condition}
    Wait Until Keyword Succeeds    30s    2s    Alarm Logs Should Be Not Empty    ${search_condition}

SAE Task Should Be Finished
    [Arguments]    ${task_name}
    ${task}    Get SAE Task    ${task_name}
    Should Be Equal As Integers    ${task['status']}    0

Wait Until SAE Task Finished
    [Arguments]    ${task_name}
    Wait Until Keyword Succeeds    120s    2s    SAE Task Should Be Finished    ${task_name}