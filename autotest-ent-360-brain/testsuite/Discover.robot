*** Settings ***
Documentation     Discover Test for Hansight Enterprise
Test Setup        Discover Test Setup
Test Teardown     Discover Test Teardown
Variables         ../config/config.py
Resource          kw_gallery.robot
Resource          kw_discover.robot
Resource          kw_ent.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_utils.robot
Resource          kw_ldap_user.robot
Resource          kw_sys_cfg.robot

*** Test Cases ***
Timeline Check
    ${time_line}    Get Timeline    source=event
    Should Not Be Empty    ${time_line}

Discover Data Check
    ${discover_data}    Get Discover Data    source=event
    Should Not Be Empty    ${discover_data['search']['data']}

Add Group
    ${description}    Set Variable    autotest_group
    ${id}    ${name}    Add Discover Group    description=${description}
    Set Suite Variable    ${group_name}    ${name}
    Set Suite Variable    ${group_id}    ${id}
    ${id}    Get Discover Group ID    ${group_name}
    Should Be Equal    ${group_id}    ${id}

Update Group
    Set Suite Variable    ${group_name}    update_${group_name}
    Update Discover Group    id=${group_id}    name=${group_name}    description=update
    ${group_info}    Get Discover Group By ID    id=${group_id}
    Should Be Equal    ${group_info['description']}    update

Delete Group
    ${parentId}    ${name}    Add Discover Group    description=test_gallery
    ${childrenId}    ${name}    Add Discover Group    description=test_gallery    parentId=${parentId}
    Run Keyword And Expect Error    *    Delete Discover Group    ${parentId}
    Delete Discover Group    ${childrenId}
    ${chartId}    Add Gallery Chart    type=上传图片    local_image=testdata/dashboard/gallery_upload_image.png    name=test上传图片    groupId=${parentId}
    ${charts}    Get Gallery Charts    groupId=${parentId}
    Should Not Be Empty    ${charts}
    Run Keyword And Expect Error    *    Delete Discover Group    ${parentId}
    Delete Gallery Chart    chart_id=${chartId}
    Delete Discover Group    ${parentId}

Download Check
    ${event_file}    Download Discover Data    source=event
    Should Not Be Empty    ${event_file}

List Topn Check
    ${source}    Set Variable    event
    ${field}    Set Variable    事件名称
    ${topn_list}    List Topn    source=${source}    field=${field}    order=desc
    Should Not Be Empty    ${topn_list}
    Run Keyword Unless    ${topn_list[0]['value'][0]}>=${topn_list[1]['value'][0]}    Fail
    ${topn_list}    List Topn    source=${source}    field=${field}    order=asc
    Run Keyword Unless    ${topn_list[0]['value'][0]}<=${topn_list[1]['value'][0]}    Fail

Save To History
    ${random_name}    Generate Random String    4    0123456789
    ${history_name}    Set Variable    history_${random_name}
    ${id_data}    Save To Discover History    source=event    name=${history_name}    publishType=${3}    group_name=root
    ${history_data}    Get Discover History Data    id=${id_data['id']}
    Should Not Be Empty    ${history_data}

Delete All History
    Delete All Discover History    source=event
    ${histories_list}    List Discover Histories    source=event    groupId=${-1}
    Should Be Empty    ${histories_list}

Update History
    ${id_data}    Save To Discover History    source=event    name=test    publishType=${3}    group_name=root
    Update Discover History    history_id=${id_data['id']}    globalFilter=事件级别 = "信息"    lockedFieldNum=${3}    name=update_history
    ${history_data}    Get Discover History Data    id=${id_data['id']}
    Should Be Equal    ${history_data['name']}    update_history
    Should Be Equal    ${history_data['globalFilter']}    事件级别 = "信息"
    Should Be Equal    ${history_data['lockedFieldNum']}    ${3}

Config Chart Check
    ${chart_result}    Config Discover Chart    chartType=LinePanel
    Should Not Be Empty    ${chart_result}
    ${chart_result}    Config Discover Chart    chartType=PiePanel
    Should Not Be Empty    ${chart_result}
    ${chart_result}    Config Discover Chart    chartType=AreaPanel
    Should Not Be Empty    ${chart_result}
    ${chart_result}    Config Discover Chart    chartType=TablePanel
    Should Not Be Empty    ${chart_result}
    ${chart_result}    Config Discover Chart    chartType=AggTablePanel
    Should Not Be Empty    ${chart_result}
    ${chart_result}    Config Discover Chart    chartType=StatPanel
    Should Not Be Empty    ${chart_result}

*** Keywords ***
Discover Test Setup
    User Login    ${default_username}    ${default_password}

Discover Test Teardown
    No Operation
