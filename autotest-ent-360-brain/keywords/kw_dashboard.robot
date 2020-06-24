*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List Dashboard
    ${list}    Module Exec    Dashboard    list
    [Return]    ${list}

Get Dashboard By ID
    [Arguments]    ${id}
    ${data}    Module Exec    Dashboard    get    id=${id}
    [Return]    ${data}

Get Dashboard By Name
    [Arguments]    ${name}
    ${data}    Module Exec    Dashboard    get_by_name    name=${name}
    [Return]    ${data}

Create Dashboard
    [Arguments]    ${name}=${EMPTY}    ${data}=${EMPTY}    &{kwargs}
    ${random_name}    Generate Random String    4    0123456789
    ${name}    Set Variable If    '${name}' == '${EMPTY}'    dashboard_${random_name}    ${name}
    ${id}    Module Exec    Dashboard    create    name=${name}    data=${data}    &{kwargs}
    [Return]    ${id}

Update Dashboard
    [Arguments]    ${id}    ${data}=${EMPTY}    &{kwargs}
    ${id}    Module Exec    Dashboard    update    id=${id}    data=${data}    &{kwargs}
    [Return]    ${id}

Delete Dashboard
    [Arguments]    ${id}
    Module Exec    Dashboard    delete    id=${id}

Delete All Dashboard
    Module Exec    Dashboard    delete_all

Get Share Info
    [Arguments]    ${id}
    ${share_info}    Module Exec    Dashboard    get_share_info    id=${id}
    [Return]    ${share_info}

Update Share Info
    [Arguments]    ${id}    &{kwargs}
    ${charts_list}    Module Exec    Dashboard    update_share_info    id=${id}    &{kwargs}
    [Return]    ${charts_list}

Get Dashboard Charts
    [Arguments]    ${dashboard_id}
    ${charts}    Module Exec    Dashboard    get_charts    id=${dashboard_id}
    [Return]    ${charts}

Add Dashboard Charts
    [Arguments]    ${dashboard_id}    ${chart_id}    &{kwargs}
    ${charts_list}    Module Exec    Dashboard    add_chart    id=${dashboard_id}    chart_id=${chart_id}    &{kwargs}
    [Return]    ${charts_list}

Update Dashboard Charts
    [Arguments]    ${dashboard_id}    ${chart_id}    &{kwargs}
    ${charts_list}    Module Exec    Dashboard    update_chart    id=${dashboard_id}    chart_id=${chart_id}    &{kwargs}
    [Return]    ${charts_list}

Delete Dashboard Charts
    [Arguments]    ${dashboard_id}    ${chart_id}
    ${charts_list}    Module Exec    Dashboard    delete_chart    id=${dashboard_id}    chart_id=${chart_id}
    [Return]    ${charts_list}

Config Charts Drilldown
    [Arguments]    ${board_name}    ${chart_name}    ${dst_name}    ${type}
    ${charts_list}    Module Exec    Dashboard    drilldown_config    board_name=${board_name}    chart_name=${chart_name}    dst_name=${dst_name}
    ...    type=${type}
