*** Settings ***
Documentation     Notification Group Test for Hansight Enterprise
Suite Setup       Notification Group Suite Setup
Suite Teardown    Notification Group Suite Teardown
Test Setup        Notification Group Test Setup
Test Teardown     Notification Group Test Teardown
Variables         ../config/config.py
Resource          kw_ent.robot
Resource          kw_utils.robot
Resource          kw_sys_cfg.robot
Resource          kw_notification_group.robot
Resource          kw_notify.robot
Resource          kw_incident.robot

*** Variables ***
${default_notification_group_id}    CQ44TMS9003d
${default_notify_id}    CQ44TMS9003d

*** Test Cases ***
Create Notification Group
    ${data_type}    Set Variable    安全事件等级
    ${value}    Set Variable    严重
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    ${notification_group_name}    Create Notification Group    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${notification_group_name}
    ${policy}=    Create Dictionary    originFilter=安全事件等级 = "严重"    translatedFilter=severity = 2
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Delete Notification Group
    @{notification_group_list}    List Notification group
    ${notification_group_id}    Create List
    : FOR    ${i}    IN    @{notification_group_list}
    \    Append To List    ${notification_group_id}    ${i['id']}
    Delete Notification Group    ${notification_group_id}
    ${notification_group_list}    List Notification Group
    ${length}    Get Length    ${notification_group_list}
    Should Be Equal    ${length}    ${1}

Create Severity Notification
    ${name}    Set Variable    警告级别通知
    ${data_type}    Set Variable    安全事件等级
    ${value}    Set Variable    警告
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    ${policy}=    Create Dictionary    originFilter=安全事件等级 = "警告"    translatedFilter=severity = 1
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create AttackBehavior Notification
    ${name}    Set Variable    告警类型通知
    ${data_type}    Set Variable    关联告警类型
    ${value}    Set Variable    漏洞利用/远程漏洞
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    ${policy}=    Create Dictionary    originFilter=关联告警类型 = "漏洞利用/远程漏洞"    translatedFilter=belongAttackBehavior(*, '10177')
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create AssetDomain Notification
    ${name}    Set Variable    资产域通知
    ${data_type}    Set Variable    资产业务域
    ${value}    Set Variable    业务系统
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    ${policy}=    Create Dictionary    originFilter=资产业务域 = "业务系统"    translatedFilter=belongAssetDomain(*, '3')
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create AssetIP Notification
    ${name}    Set Variable    影响资产通知
    ${data_type}    Set Variable    影响资产
    ${value}    Set Variable    信息管理/IP类信息/重要服务器资产IP
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    ${policy}=    Create Dictionary    originFilter=影响资产 = "信息管理/IP类信息/重要服务器资产IP"    translatedFilter=belongAsset(*, '6JUS82AW1dd1')
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create And Notification
    ${name}    Set Variable    and_test
    ${data_type_1}    Set Variable    影响资产
    ${value_1}    Set Variable    信息管理/IP类信息/漏洞扫描器IP
    ${policy_1}    Create Policy Data    data_type=${data_type_1}    value=${value_1}
    ${data_type_2}    Set Variable    安全事件等级
    ${value_2}    Set Variable    严重
    ${policy_2}    Create Policy Data    data_type=${data_type_2}    value=${value_2}
    ${originFilter}    catenate    ${policy_1['originFilter']}    and    ${policy_2['originFilter']}
    ${translatedFilter}    catenate    ${policy_1['translatedFilter']}    and    ${policy_2['translatedFilter']}
    ${policy} =    Create Dictionary    originFilter=${originFilter}    translatedFilter=${translatedFilter}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create Not Notification
    ${name}    Set Variable    not_test
    ${data_type}    Set Variable    安全事件等级
    ${value}    Set Variable    提醒
    ${policy}    Create Policy Data    data_type=${data_type}    value=${value}
    ${originFilter}    catenate    not    ${policy['originFilter']}
    ${translatedFilter}    catenate    not ${policy['translatedFilter']}
    ${policy} =    Create Dictionary    originFilter=${originFilter}    translatedFilter=${translatedFilter}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Create OR Notification
    ${name}    Set Variable    or_test
    ${data_type_1}    Set Variable    关联告警类型
    ${value_1}    Set Variable    漏洞利用/远程漏洞
    ${policy_1}    Create Policy Data    data_type=${data_type_1}    value=${value_1}
    ${data_type_2}    Set Variable    资产业务域
    ${value_2}    Set Variable    业务系统
    ${policy_2}    Create Policy Data    data_type=${data_type_2}    value=${value_2}
    ${originFilter}    catenate    ${policy_1['originFilter']}    or    ${policy_2['originFilter']}
    ${translatedFilter}    catenate    ${policy_1['translatedFilter']}    or    ${policy_2['translatedFilter']}
    ${policy} =    Create Dictionary    originFilter=${originFilter}    translatedFilter=${translatedFilter}
    Create Notification Group    name=${name}    notify_id=${default_notify_id}    policy=${policy}
    ${notification_group_data}    Get Notification Group By Name    name=${name}
    Should Be Equal    ${policy}    ${notification_group_data['policy']}

Update Notifictaion Group
    ${new_type}    Set Variable    安全事件等级
    ${new_value}    Set Variable    严重
    ${new_policy}    Create Policy Data    data_type=${new_type}    value=${new_value}
    Update Notification Group    id=${default_notification_group_id}    notify_id=${default_notify_id}    policy=${new_policy}
    ${notification_group_info}    Get Notification Group    id=${default_notification_group_id}
    ${policy}=    Create Dictionary    originFilter=安全事件等级 = "严重"    translatedFilter=severity = 2
    Should Be Equal    ${policy}    ${notification_group_info['policy']}

Config Incident Rule Notification
    ${notification_group_list}    List Notification Group
    ${notification}=    Create List    ${notification_group_list[0]['id']}
    ${notifier}=    Create List    ${default_notify_id}
    ${ice_rules}=    Get All Incident Rules
    ${icerule_id}    Set Variable    ${ice_rules[0]['id']}
    Update Incident Rule Notification    id=${icerule_id}    notifier=${notifier}    notification=${notification}
    ${rule_data}    Get Incident Rule    id=${icerule_id}
    Should Be Equal    ${rule_data['notifier']}    ${notifier}
    Should Be Equal    ${rule_data['notification']}    ${notification}

*** Keywords ***
Notification Group Suite Setup
    User Login    ${default_username}    ${default_password}

Notification Group Suite Teardown
    No Operation

Notification Group Test Teardown
    No Operation

Notification Group Test Setup
    User Login    ${default_username}    ${default_password}
