*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get Alarm Detail
    [Arguments]    ${id}
    ${alarm_detail}    Module Exec    Alarm    get_detail    id=${id}
    [Return]    ${alarm_detail}

Get Alarm DetailList
    [Arguments]    ${alarm_key}
    ${alarm_list}    Module Exec    Alarm    get_alarm_detail_list    alarm_key=${alarm_key}
    [Return]    ${alarm_list}

Get Alarm Related Event DetailList
    [Arguments]    ${node_chain}    ${event_ids}
    ${event_list}    Module Exec    Alarm    get_event_detail_list    node_chain=${node_chain}    event_ids=${event_ids}
    [Return]    ${event_list}

Update Confirmed Alarm Status
    [Arguments]    ${id}    ${index}
    ${content}    Module Exec    Alarm    update_alarm_status_confirmed    id=${id}    _index=${index}
    [Return]    ${content}

Update Unconfirmed Alarm Status
    [Arguments]    ${id}    ${index}
    ${content}    Module Exec    Alarm    update_alarm_status_unconfirmed    id=${id}    _index=${index}
    [Return]    ${content}

Update ErrorConfirmed Alarm Status
    [Arguments]    ${id}    ${index}
    ${content}    Module Exec    Alarm    update_alarm_status_error    id=${id}    _index=${index}
    [Return]    ${content}

Get Ti Basic Info
    [Arguments]    ${ioc}
    ${content}    Module Exec    Alarm    get_ti_basic_info    ioc=${ioc}
    [Return]    ${content}

Get Ti Port Info
    [Arguments]    ${ip}
    ${content}    Module Exec    Alarm    get_ti_portinfo    ip=${ip}
    [Return]    ${content}

Get Ti Related Info
    [Arguments]    ${ioc}
    ${content}    Module Exec    Alarm    get_ti_related_info     ioc=${ioc}
    [Return]    ${content}
