*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get Timeline
    [Arguments]    ${source}    ${filter_expression}=${EMPTY}    &{kwargs}
    ${time_line}    Module Exec    Discover    get_timeline    source=${source}    filter_expression=${filter_expression}    &{kwargs}
    [Return]    ${time_line}

Get Discover Data
    [Arguments]    ${source}    &{kwargs}
    ${discover_data}    Module Exec    Discover    get_discover_data    source=${source}    &{kwargs}
    [Return]    ${discover_data}

List Topn
    [Arguments]    ${source}    ${field}    ${filter_expression}=${EMPTY}    &{kwargs}
    ${topn_list}    Module Exec    Discover    get_topn_list    source=${source}    field=${field}    filter_expression=${filter_expression}
    ...    &{kwargs}
    [Return]    ${topn_list}

List Discover Groups
    ${groups_list}    Module Exec    Discover    groups_list
    [Return]    ${groups_list}

Add Discover Group
    [Arguments]    ${name}=${EMPTY}    ${description}=${EMPTY}    ${parentId}=${EMPTY}
    ${random_name}    Generate Random String    4    0123456789
    ${name}    Set Variable If    '${name}' == '${EMPTY}'    group_${random_name}    ${name}
    ${parentId}    Set Variable If    '${parentId}' == '${EMPTY}'    -1    ${parentId}
    ${group_id}    Module Exec    Discover    add_group    name=${name}    description=${description}    parentId=${parentId}
    [Return]    ${group_id}    ${name}

Get Discover Group ID
    [Arguments]    ${name}
    ${group_id}    Module Exec    Discover    get_group_id    name=${name}
    [Return]    ${group_id}

Get Discover Group By ID
    [Arguments]    ${id}
    ${group_info}    Module Exec    Discover    get_group_by_id    id=${id}
    [Return]    ${group_info}

Update Discover Group
    [Arguments]    ${id}    ${data}=${EMPTY}    &{kwargs}
    Module Exec    Discover    update_group    id=${id}    data=${data}    &{kwargs}

Delete Discover Group
    [Arguments]    ${id}
    Module Exec    Discover    delete_group    id=${id}

Delete All Discover Group
    Module Exec    Discover    delete_all_group

List Discover Histories
    [Arguments]    ${source}    ${groupId}
    ${histories_list}    Module Exec    Discover    get_histories_list    source=${source}    groupId=${groupId}
    [Return]    ${histories_list}

Get Discover History ID
    [Arguments]    ${source}    ${name}
    ${history_id}    Module Exec    Discover    get_history_id    source=${source}    name=${name}
    [Return]    ${history_id}

Delete Discover History
    [Arguments]    ${id}
    ${history_id}    Module Exec    Discover    delete_history    id=${id}
    [Return]    ${history_id}

Delete All Discover History
    [Arguments]    ${source}    ${groupId}=${EMPTY}
    Module Exec    Discover    delete_all_history    source=${source}    groupId=${groupId}

Get Discover History Data
    [Arguments]    ${id}
    ${history_data}    Module Exec    Discover    get_history_data    id=${id}
    [Return]    ${history_data}

Save To Discover History
    [Arguments]    ${source}    ${name}    ${publishType}    ${group_name}    &{kwargs}
    ${id_data}    Module Exec    Discover    save_to_history    source=${source}    name=${name}    publishType=${publishType}
    ...    group_name=${group_name}    &{kwargs}
    [Return]    ${id_data}

Update Discover History
    [Arguments]    ${history_id}    ${data}=${EMPTY}    &{kwargs}
    ${id_data}    Module Exec    Discover    update_history    history_id=${history_id}    data=${data}    &{kwargs}
    [Return]    ${id_data}

Get Discover Field Key
    [Arguments]    ${source}    ${name}
    ${filed_key}    Module Exec    DiscoverMeta    get_field_key    source=${source}    name=${name}
    [Return]    ${filed_key}

Download Discover Data
    [Arguments]    ${source}    &{kwargs}
    ${file_id}    Module Exec    Discover    download    source=${source}    &{kwargs}
    [Return]    ${file_id}

Get History All Charts
    [Arguments]    ${history_id}
    Moudle Exec    DiscoverCharts    get_history_charts    history_id=${history_id}

Get Discover Chart
    [Arguments]    ${name}    ${history_id}
    ${chart_id}    Moudle Exec    DiscoverCharts    get_chart_ID    name=${name}    history_id=${history_id}
    [Return]    ${chart_id}

Get Discover Chart By ID
    [Arguments]    ${history_id}    ${chart_id}
    ${chart_data}    Moudle Exec    DiscoverCharts    get_chart_by_id    history_id=${history_id}    chart_id=${chart_id}
    [Return]    ${chart_data}

Config Discover Chart
    [Arguments]    ${chartType}    &{kwargs}
    ${chart_result}    Module Exec    DiscoverCharts    config_chart    chartType=${chartType}    &{kwargs}
    [Return]    ${chart_result}
