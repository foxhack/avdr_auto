*** Settings ***
Documentation     Angler Test for Hansight Enterprise
Test Setup        Angler Test Setup
Test Teardown     Angler Test Teardown
Suite Setup       Angler Suite Setup
Resource          kw_ent.robot
Resource          kw_sys_cfg.robot
Resource          kw_cep.robot
Resource          kw_dataviewer.robot

*** Variables ***


*** Test Cases ***
Aggregation Type - Count
    ${condition}    Set Variable    (告警名称 = "聚合-count")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Distinct Count
    ${condition}    Set Variable    (告警名称 = "聚合-distinct count")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Sum
    ${condition}    Set Variable    (告警名称 = "聚合-sum")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Avg
    ${condition}    Set Variable    (告警名称 = "聚合-avg")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Max
    ${condition}    Set Variable    (告警名称 = "聚合-max")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Min
    ${condition}    Set Variable    (告警名称 = "聚合-min")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Variance
    ${condition}    Set Variable    (告警名称 = "聚合-方差")
    Wait Until Alarm Logs Generated    ${condition}

Aggregation Type - Standard Deviation
    ${condition}    Set Variable    (告警名称 = "聚合-标准差")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Count
    ${condition}    Set Variable    (告警名称 = "同比-聚合-count")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Distinct Count
    ${condition}    Set Variable    (告警名称 = "同比-聚合-distinct count")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Sum
    ${condition}    Set Variable    (告警名称 = "同比-聚合-sum")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Avg
    ${condition}    Set Variable    (告警名称 = "同比-聚合-avg")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Max
    ${condition}    Set Variable    (告警名称 = "同比-聚合-max")
    Wait Until Alarm Logs Generated    ${condition}

Comparison Type - Min
    ${condition}    Set Variable    (告警名称 = "同比-聚合-min")
    Wait Until Alarm Logs Generated    ${condition}


*** Keywords ***
Angler Test Setup
    User Login    ${default_username}    ${default_password}

Angler Test Teardown
    No Operation

Angler Suite Setup
    User Login    ${default_username}    ${default_password}
    Init System Import Module    testdata/cep/test_angler_rule_full.zip
    Create DV Collector with Parser Rules    测试规则-勿删除
    Send Data    2,148.10.21.154,4499,172.16.100.11,3669,4
    Sleep    240

Alarm Logs Should Be Not Empty
    [Arguments]    ${search_condition}
    ${cnt}    Query Alarm Logs Count    Condition=${search_condition}
    Should Not Be Equal As Integers    ${cnt}    0

Wait Until Alarm Logs Generated
    [Arguments]    ${search_condition}
    Wait Until Keyword Succeeds    60s    10s    Alarm Logs Should Be Not Empty    ${search_condition}