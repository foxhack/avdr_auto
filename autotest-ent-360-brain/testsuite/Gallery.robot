*** Settings ***
Documentation     Gallery Test for Hansight Enterprise
Test Setup        Gallery Test Setup
Test Teardown     Gallery Test Teardown
Variables         ../config/config.py
Resource          kw_ent.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_utils.robot
Resource          kw_ldap_user.robot
Resource          kw_sys_cfg.robot
Resource          kw_gallery.robot
Resource          kw_discover.robot

*** Variables ***
${local_image}    testdata/dashboard/gallery_upload_image.png

*** Test Cases ***
Add Charts To Gallery
    ${charts_list}    Get Gallery Charts
    : FOR    ${chart}    IN    @{charts_list}
    \    Delete Gallery Chart    chart_id=${chart['id']}
    ${charts_list}    Get Gallery Charts
    ${before}    Get Length    ${charts_list}
    ${chartA_id}    Add Gallery Chart    type=外部网页    url=https://www.baidu.com    name=test外部网页
    ${chartB_id}    Add Gallery Chart    type=外部图片    url=https://goss1.vcg.com/creative/vcg/400/version23/VCG41562878349.jpg    name=test外部图片
    ${local_image}    Set Variable    testdata/dashboard/gallery_upload_image.png
    ${chartC_id}    Add Gallery Chart    type=上传图片    local_image=${local_image}    name=test上传图片
    ${id_data}    Save To Discover History    source=event    name=testBI图表    publishType=${1}    group_name=root
    ${chart}    Get Gallery Chart By ID    chart_id=${chartA_id}
    Should Be Equal    ${chart['name']}    test外部网页
    Should Be Equal    ${chart['url']}    https://www.baidu.com
    ${charts_list}    Get Gallery Charts
    ${after}    Get Length    ${charts_list}
    ${length}    Evaluate    ${after}-${before}
    Should Be Equal    ${length}    ${4}

Update Chart
    ${chart_id}    Add Gallery Chart    type=外部网页    url=https://www.baidu.com    name=test外部网页
    Update Gallery Chart    chart_id=${chart_id}    name=update_chart    url=https://www.sogo.com
    ${chart}    Get Gallery Chart By ID    chart_id=${chart_id}
    Should Be Equal    ${chart['name']}    update_chart

Delete All Chart
    ${charts_list}    Get Gallery Charts
    : FOR    ${chart}    IN    @{charts_list}
    \    Delete Gallery Chart    chart_id=${chart['id']}
    ${list}    Get Gallery Charts
    ${length}    Get Length    ${list}
    Should Be Equal    ${length}    ${0}

*** Keywords ***
Gallery Test Setup
    User Login    ${default_username}    ${default_password}

Gallery Test Teardown
    No Operation
