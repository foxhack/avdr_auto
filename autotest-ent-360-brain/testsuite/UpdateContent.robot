*** Settings ***
Documentation     UpdateContent Test for Hansight Enterprise
Suite Setup       UpdateContent Suite Setup
Suite Teardown    UpdateContent Suite Teardown
Test Setup        UpdateContent Test Setup
Test Teardown     UpdateContent Test Teardown
Resource          kw_ent.robot
Resource          kw_sys_cfg.robot
Resource          kw_event.robot
Resource          kw_asset.robot
Resource          kw_cep.robot
Resource          kw_utils.robot
Resource          kw_notify.robot
Resource          kw_incident.robot
Resource          kw_intelligence.robot

*** Variables ***
@{notification}    CQ44TMS9003d
@{notifier}       CQ44TMS9003d

*** Test Cases ***
IceRule Update Notification
    ${data}    Get Incident Rule By Name    name=test内网主机被攻击后连接矿池
    Should Be Equal    ${data['notification']}    @{notification}
    Should Be Equal    ${data['notifier']}    @{notifier}

Delete Intelligence
    ${list}    List Intelligence Group
    ${id}    set variable    ${list[0]['id']}
    Delete Intelligence    id=${id}
    Init System Import Module    testdata/init/export_update_information.zip
    Run Keyword And Expect Error    *    Get Intelligence    id=${id}

*** Keywords ***
UpdateContent Suite Setup
    User Login    ${default_username}    ${default_password}
    Init System Import Module    testdata/init/export_update_user.zip
    Init System Import Module    testdata/init/export_update.zip

UpdateContent Suite Teardown
    No Operation

UpdateContent Test Teardown
    No Operation

UpdateContent Test Setup
    User Login    ${default_username}    ${default_password}
