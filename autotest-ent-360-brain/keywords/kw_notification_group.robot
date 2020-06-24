*** Settings ***
Variables         ../config/config.py
Resource          kw_utils.robot

*** Keywords ***
Delete Notification Group
    [Arguments]    ${id}
    Module Exec    NotificationGroup    delete    id=${id}

Update Notification Group
    [Arguments]    ${id}    &{kwargs}
    Module Exec    NotificationGroup    update    id=${id}    &{kwargs}

List Notification Group
    ${notification_group_list}    Module Exec    NotificationGroup    list
    [Return]    ${notification_group_list}

Get Notification Group
    [Arguments]    ${id}
    ${notification_group_info}    Module Exec    NotificationGroup    get    id=${id}
    [Return]    ${notification_group_info}

Create Notification Group
    [Arguments]    ${policy}    ${notify_id}    ${name}=${EMPTY}    ${data}=${EMPTY}
    ${random_name}    Generate Random String    4    0123456789
    ${notification_group_name}    Set Variable If    '${name}' == '${EMPTY}'    notification_group_${random_name}    ${name}
    Module Exec    NotificationGroup    create    name=${notification_group_name}    notify_id=${notify_id}    policy=${policy}    data=${data}
    [Return]    ${notification_group_name}

Get Notification Group By Name
    [Arguments]    ${name}
    ${notification_group}    Module Exec    NotificationGroup    get_by_name    name=${name}
    [Return]    ${notification_group}

Create Policy Data
    [Arguments]    ${data_type}    ${value}
    ${policy}    Module Exec    NotificationGroup    policy_data    data_type=${data_type}    value=${value}
    [Return]    ${policy}
