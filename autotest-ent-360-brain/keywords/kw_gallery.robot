*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get Gallery Charts
    [Arguments]    ${groupId}=${EMPTY}
    ${charts_data}    Run Keyword If    '${groupId}'!='${EMPTY}'    Module Exec    Gallery    get_charts    groupId=${groupId}
    ...    ELSE    Module Exec    Gallery    get_charts
    [Return]    ${charts_data}

Get Gallery Chart By ID
    [Arguments]    ${chart_id}
    ${chart_data}    Module Exec    Gallery    get_chart_by_id    id=${chart_id}
    [Return]    ${chart_data}

Get Gallery Chart By Name
    [Arguments]    ${name}
    ${chart_data}    Module Exec    Gallery    get_chart_by_name    name=${name}
    [Return]    ${chart_data}

Add Gallery Chart
    [Arguments]    ${type}    ${url}=${EMPTY}    ${local_image}=${EMPTY}    ${name}=${EMPTY}    ${groupId}=-1
    log    ${type}
    ${groupId}    Set Variable If    '${groupId}' == '${EMPTY}'    -1    ${groupId}
    ${random_name}    Generate Random String    4    0123456789
    ${name}    Set Variable If    '${name}' == '${EMPTY}'    chart_${random_name}    ${name}
    ${charts_id}    Module Exec    Gallery    add_chart    type=${type}    name=${name}    url=${url}
    ...    local_image=${local_image}    groupId=${groupId}
    [Return]    ${charts_id}

Update Gallery Chart
    [Arguments]    ${chart_id}    &{kwargs}
    Module Exec    Gallery    update_chart    id=${chart_id}    &{kwargs}

Delete Gallery Chart
    [Arguments]    ${chart_id}
    Module Exec    Gallery    delete_chart    id=${chart_id}
