*** Settings ***
Documentation     Dashboard Test for Hansight Enterprise
Test Setup        Dashboard Test Setup
Test Teardown     Dashboard Test Teardown
Variables         ../config/config.py
Resource          kw_ent.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_utils.robot
Resource          kw_ldap_user.robot
Resource          kw_sys_cfg.robot
Resource          kw_gallery.robot
Resource          kw_dashboard.robot
Resource          kw_discover.robot

*** Test Cases ***
Create Dashboard
    ${dashboard_id}    Create Dashboard
    ${data}    List Dashboard
    Should Not Be Empty    ${data['list']}

Create Renamed Dashboard
    ${data}    List Dashboard
    ${dashbord_name}    Set Variable    ${data['list'][0]['name']}
    ${msg}    Run Keyword And Expect Error    *    Create Dashboard    name=${dashbord_name}
    Should Contain    ${msg}    仪表盘名称已存在！

Delete All Dashboard
    Delete All Dashboard
    ${data}    List Dashboard
    Should Be Empty    ${data['list']}

Update Dashboard
    ${dashboard_id}    Create Dashboard
    ${data}    Get Dashboard By ID    ${dashboard_id}
    Update Dashboard    id=${dashboard_id}    name=update@_${data['name']}
    ${update_data}    Get Dashboard By Name    name=update@_${data['name']}
    Should Not Be Empty    ${update_data}

Update Renamed Dashboard
    ${data}    List Dashboard
    ${dashbord_name}    Set Variable    ${data['list'][0]['name']}
    ${dashboard_id}    Create Dashboard
    ${data}    Get Dashboard By ID    ${dashboard_id}
    ${msg}    Run Keyword And Expect Error    *    Update Dashboard    id=${dashboard_id}    name=${dashbord_name}
    Should Contain    ${msg}    仪表盘名称已存在！

Add Chart To Dashboard
    ${charts_id}    Create Gallery Charts
    ${dashboard_id}    Create Dashboard
    Add Dashboard Charts    dashboard_id=${dashboard_id}    chart_id=${charts_id[0]}
    Should Not Be Empty    Get Dashboard Charts    dashboard_id=${dashboard_id}

Update Gallery Charts
    ${charts_id}    Create Gallery Charts
    ${dashboard_id}    Create Dashboard
    Add Dashboard Charts    dashboard_id=${dashboard_id}    chart_id=${charts_id[1]}
    Update Gallery Chart    chart_id=${charts_id[1]}    name=update_chart    url=https://www.sogo.com
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard_id}
    Should Be Equal    ${charts['list'][0]['name']}    update_chart

Update Charts Position
    ${charts_id}    Create Gallery Charts
    ${chart_id}    Set Variable    ${charts_id[1]}
    ${dashboard_id}    Create Dashboard
    Add Dashboard Charts    dashboard_id=${dashboard_id}    chart_id=${chart_id}
    Update Dashboard Charts    dashboard_id=${dashboard_id}    chart_id=${chart_id}    left=11
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard_id}
    Should Be Equal    ${charts['list'][0]['position']['left']}    ${11}

Delete Gallery Charts
    ${charts_id}    Create Gallery Charts
    ${chart_id}    Set Variable    ${charts_id[0]}
    ${dashboard_id}    Create Dashboard
    Add Dashboard Charts    dashboard_id=${dashboard_id}    chart_id=${chart_id}
    Delete Gallery Chart    chart_id=${chart_id}
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard_id}
    Should Be Empty    ${charts['list']}

Update Dashboard ShareInfo
    ${dashboard_id}    Create Dashboard
    Update Share Info    id=${dashboard_id}    shareType=open
    ${share_info}    Get Share Info    id=${dashboard_id}
    Should Be Equal    ${share_info['shareType']}    ${0}
    @{roles}    Create List    系统管理员
    ${user_name_1}    Add User    roles=@{roles}
    BuiltIn.Sleep    5
    ${user_name_2}    Add User    roles=@{roles}
    ${users}    Create List    ${user_name_1}    ${user_name_2}
    Update Share Info    id=${dashboard_id}    shareType=specific    users=${users}
    ${share_info}    Get Share Info    id=${dashboard_id}
    Should Be Equal    ${share_info['shareType']}    ${2}

Config Charts Drilldown To Incident List
    Init System Import Module    testdata/init/export_dashboard.zip
    ${board_name}    Set Variable    Incident KPI
    ${chart_name}    Set Variable    近30天类型趋势图
    ${dst_name}    Set Variable    安全事件列表
    ${target}    Set Variable    url
    Config Charts Drilldown    board_name=${board_name}    chart_name=${chart_name}    dst_name=${dst_name}    type=${target}
    ${drilldown}=    Create Dictionary    name=${dst_name}    target=${target}
    ${dashboard}    Get Dashboard By Name    name=${board_name}
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard['id']}
    @{charts_list}    Set Variable    ${charts['list']}
    : FOR    ${chart}    IN    @{charts_list}
    \    Run Keyword If    '${chart['name']}'=='${chart_name}'    Exit For Loop
    Should Be Equal    ${chart['drilldown']['name']}    ${drilldown['name']}

Config Charts Drilldown To Incident Detail
    ${board_name}    Set Variable    Incident KPI
    ${chart_name}    Set Variable    最近24小时类型分布图
    ${dst_name}    Set Variable    安全事件详情
    ${target}    Set Variable    url
    Config Charts Drilldown    board_name=${board_name}    chart_name=${chart_name}    dst_name=${dst_name}    type=${target}
    ${drilldown}=    Create Dictionary    name=${dst_name}    target=${target}
    ${dashboard}    Get Dashboard By Name    name=${board_name}
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard['id']}
    @{charts_list}    Set Variable    ${charts['list']}
    : FOR    ${chart}    IN    @{charts_list}
    \    Run Keyword If    '${chart['name']}'=='${chart_name}'    Exit For Loop
    Should Be Equal    ${chart['drilldown']['name']}    ${drilldown['name']}

Config Charts Drilldown To Board
    ${board_name}    Set Variable    网站安全
    ${chart_name}    Set Variable    webshell事件统计
    ${dst_name}    Set Variable    网站安全-webshell
    ${target}    Set Variable    dashboard
    Config Charts Drilldown    board_name=${board_name}    chart_name=${chart_name}    dst_name=${dst_name}    type=${target}
    ${drilldown}=    Create Dictionary    name=${dst_name}    target=${target}
    ${dashboard}    Get Dashboard By Name    name=${board_name}
    ${charts}    Get Dashboard Charts    dashboard_id=${dashboard['id']}
    @{charts_list}    Set Variable    ${charts['list']}
    : FOR    ${chart}    IN    @{charts_list}
    \    Run Keyword If    '${chart['name']}'=='${chart_name}'    Exit For Loop
    Should Be Equal    ${chart['drilldown']['name']}    ${drilldown['name']}

*** Keywords ***
Dashboard Test Setup
    User Login    ${default_username}    ${default_password}

Dashboard Test Teardown
    No Operation

Create Gallery Charts
    ${chartA_id}    Add Gallery Chart    type=外部网页    url=https://www.baidu.com    name=test外部网页
    ${chartB_id}    Add Gallery Chart    type=外部图片    url=https://www.sohu.com    name=test外部图片
    ${local_image}    Set Variable    testdata/dashboard/gallery_upload_image.png
    ${chartC_id}    Add Gallery Chart    type=上传图片    local_image=${local_image}    name=test上传图片
    ${id_data}    Save To Discover History    source=event    name=testBI图表    publishType=${1}    group_name=root
    ${chartD_id}    Set Variable    ${id_data['charts'][0]['id']}
    [Return]    ${chartA_id}    ${chartB_id}    ${chartC_id}    ${chartD_id}
