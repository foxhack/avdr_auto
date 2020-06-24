*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List History Task
    ${list}    Module Exec    HistoryTask    list
    [Return]    ${list}

Get History Task
    [Arguments]    ${name}
    ${task_info}    Module Exec    HistoryTask    get_task    name=${name}
    [Return]    ${task_info}

Add History Task
    [Arguments]    ${ruleId_list}    ${name}=${EMPTY}    &{kwargs}
    ${random_name}    Generate Random String    4    0123456789
    ${name}    Set Variable If    '${name}' == '${EMPTY}'    task_${random_name}    ${name}
    Module Exec    HistoryTask    create    name=${name}    ruleId_list=${ruleId_list}    &{kwargs}
    [Return]    ${name}

Get HistoryTask By Id
    [Arguments]    ${id}
    ${task_info}    Module Exec    HistoryTask    get_task    id=${id}

List History Alarm
    [Arguments]    ${beginTime}    ${endTime}    ${id}
    ${history_alarm_list}    Module Exec    HistoryTask    alarmHistory    endTime=${endTime}    beginTime=${beginTime}    id=${id}
    [Return]    ${history_alarm_list}

Delete Task By Id
    [Arguments]    ${id}
    Module Exec    HistoryTask    delete    id=${id}
