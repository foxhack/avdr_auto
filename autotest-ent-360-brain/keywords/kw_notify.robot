*** Settings ***
Variables         ../config/config.py
Resource          kw_utils.robot

*** Keywords ***
Delete Notify
    [Arguments]    ${id}
    Module Exec    Notification    delete    id=${id}

Update Notify
    [Arguments]    ${id}    ${data}=${EMPTY}    &{kwargs}
    Module Exec    Notification    update    id=${id}    data=${data}    &{kwargs}

List Notify
    ${notify_list}    Module Exec    Notification    list
    [Return]    ${notify_list}

Get Notify
    [Arguments]    ${id}
    ${notify_info}    Module Exec    Notification    get    id=${id}
    [Return]    ${notify_info}

Create Notify
    [Arguments]    ${name}=${EMPTY}    ${mailEnabled}=${EMPTY}    ${emails}=${EMPTY}    ${smsEnabled}=${EMPTY}    ${phoneNumbers}=${EMPTY}    ${cmdEnabled}=${EMPTY}
    ...    ${cmd}=${EMPTY}    ${data}=${EMPTY}
    ${random_name}    Generate Random String    4    0123456789
    ${name}    Set Variable If    '${name}' == '${EMPTY}'    notify_${random_name}    ${name}
    Module Exec    Notification    create    name=${name}    emails=${emails}    phoneNumbers=${phoneNumbers}    cmd=${cmd}
    ...    data=${data}    smsEnabled=${smsEnabled}    cmdEnabled=${cmdEnabled}    mailEnabled=${mailEnabled}
    [Return]    ${name}

Get Notify By Name
    [Arguments]    ${name}
    ${notify}    Module Exec    Notification    get_by_name    name=${name}
    [Return]    ${notify}

Get Mail
    [Arguments]    ${server}=${EMPTY}    ${username}=${EMPTY}    ${password}=${EMPTY}
    ${mail_subject}    Module Exec    Notification    checkMail    server=${server}    username=${username}    password=${password}
    [Return]    ${mail_subject}

Get Default Notify
    ${Default Notify}    Get Notify By Name    ${default_notify_name}
    ${id}    Set Variable    ${Default Notify['id']}
    [Return]    ${id}
