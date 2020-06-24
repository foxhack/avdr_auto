*** Settings ***
Variables         ../config/config.py
Resource          kw_utils.robot

*** Keywords ***
List Intelligence Group
    ${intelligence_group_list}    Module Exec    IntelligenceGroup    list
    [Return]    ${intelligence_group_list}

List Intelligence
    ${intelligence_list}    Module Exec    Intelligence    list
    [Return]    ${intelligence_list}

Get Intelligence
    [Arguments]    ${id}
    ${intelligence_data}    Module Exec    Intelligence    get    id=${id}
    [Return]    ${intelligence_data}

Get Intelligence By Name
    [Arguments]    ${name}
    ${intelligence_data}    Module Exec    Intelligence    get_by_name    name=${name}
    [Return]    ${intelligence_data}

Delete Intelligence
    [Arguments]    ${id}
    Module Exec    Intelligence    delete    id=${id}
