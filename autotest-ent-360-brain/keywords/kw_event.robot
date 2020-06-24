*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List Discover Groups
    ${list_event_parsers}    Module Exec    EventParser    list
    [Return]    ${list_event_parsers}

Get Event Parser
    [Arguments]    ${name}
    ${rule_info}    Module Exec    EventParser    get_by_name    name=${name}
    [Return]    ${rule_info}
