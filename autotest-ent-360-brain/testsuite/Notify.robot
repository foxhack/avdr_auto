*** Settings ***
Documentation     Notify Test for Hansight Enterprise
Suite Setup       Notify Suite Setup
Suite Teardown    Notify Suite Teardown
Test Setup        Notify Test Setup
Test Teardown     Notify Test Teardown
Variables         ../config/config.py
Resource          kw_ent.robot
Resource          kw_event.robot
Resource          kw_alarm.robot
Resource          kw_cep.robot
Resource          kw_utils.robot
Resource          kw_sys_cfg.robot
Resource          kw_notify.robot

*** Test Cases ***
Create Notify
    ${phoneNumbers}    Generate Random PhoneNumbers
    ${smtp_data}    Get SMTP
    ${name1}    Create Notify    smsEnabled=${1}    phoneNumbers=${phoneNumbers}
    ${name2}    Create Notify    mailEnabled=${1}    emails=${smtp_data['data']['username']}
    ${name3}    Create Notify    cmdEnabled=1    cmd=sms.sh
    ${name4}    Create Notify    smsEnabled=${1}    phoneNumbers=${phoneNumbers}    mailEnabled=${1}    emails=${smtp_data['data']['username']}    cmdEnabled=1
    ...    cmd=sms.sh
    ${notify1}    Get Notify By Name    ${name1}
    ${notify2}    Get Notify By Name    ${name2}
    ${notify3}    Get Notify By Name    ${name3}
    ${notify4}    Get Notify By Name    ${name4}
    Should Not Be Empty    ${notify1}
    Should Not Be Empty    ${notify2}
    Should Not Be Empty    ${notify3}
    Should Not Be Empty    ${notify4}

Delete Notify
    @{notify_list}    List Notify
    ${notify_id}    Create List
    : FOR    ${i}    IN    @{notify_list}
    \    Append To List    ${notify_id}    ${i['id']}
    log    ${notify_id}
    Delete Notify    ${notify_id}
    ${default id}    Get Default Notify
    ${notify_list}    List Notify
    Should Be Equal    ${notify_list[0]['id']}    ${default id}

Update Notify
    ${default id}    Get Default Notify
    ${smtp_data}    Get SMTP
    Update Notify    id=${default id}    mailEnabled=${1}    emails=${smtp_data['data']['username']}
    ${notify_info}    Get Notify    ${default id}
    Should Be Equal    ${notify_info['mailEnabled']}    ${1}
    Should Be Equal    ${notify_info['emails']}    ${smtp_data['data']['username']}

*** Keywords ***
Notify Suite Setup
    [Documentation]    suite setup operation, import license, and create collector
    User Login    ${default_username}    ${default_password}

Notify Suite Teardown
    @{notify_list}    List Notify
    : FOR    ${i}    IN    @{notify_list}
    \    Delete Notify    ${i['id']}

Notify Test Teardown
    No Operation

Notify Test Setup
    User Login    ${default_username}    ${default_password}
