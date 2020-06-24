*** Settings ***
Test Setup        Incident Test Setup
Test Teardown     Incident Test Teardown
Resource          kw_ent.robot
Resource          kw_incident.robot
Resource          kw_sys_cfg.robot
Resource          kw_cep.robot
Resource          kw_dataviewer.robot
Resource          kw_user.robot
Library           String

*** Variables ***
@{alarm_level}    致命    严重    警告    提醒
@{confirmation_status}    0    1    2    3    # 0-未知 \ \ 1-攻击成功 \ 2-攻击失败 \ 3 误报
@{handle_status}    0    1    2    3    # 0-处置中 \ \ 1-待处置 \ 2-处置完成 \ 3 忽略
${default_condition}    (规则名称 = "NDR默认策略" and 标题 rlike ".*test-sum.*")

*** Test Cases ***
Query All Incident
    ${data}=    Search Incident List
    Should Not Be Empty    ${data}

Delete One Incident
    ${data}=    Search Incident List
    Delete Incident    ${data[0]['id']}
    ${result}=    Search Incident List    ID = "${data[0]['name']}"
    Should Be Empty    ${result}

Modify Incident Owner
    ${data}=    Search Incident List
    ${user}=    List User
    Change Incident To Owner    ${data[0]['id']}    ${user[0]['id']}
    ${result}=    Search Incident List    责任人 = "${user[0]['realName']}"
    Should Be Equal As Strings    ${data[0]['id']}    ${result[0]['id']}

Modify Incident Handle Status
    ${data}=    Search Incident List
    Handle Incident To Status    ${data[0]['id']}    ${handle_status[2]}
    ${result}=    Search Incident List    处置状态 = "处置完成" AND ID = "${data[0]['name']}"
    Should Be Equal As Strings    ${data[0]['id']}    ${result[0]['id']}
    ${history}=    Get Incident Status Change History    ${data[0]['id']}
    Should Not Be Empty    ${history}

Modify Incident Confirm Status
    ${data}=    Search Incident List
    Confirm Incident To Status    ${data[0]['id']}    ${confirmation_status[2]}
    ${result}=    Search Incident List    确认状态 = "攻击失败" AND ID = "${data[0]['name']}"
    Should Be Equal As Strings    ${data[0]['id']}    ${result[0]['id']}
    ${history}=    Get Incident Status Change History    ${data[0]['id']}
    Should Not Be Empty    ${history}

Check Incident Latest Event and Alert Count
    ${data}=    Search Incident List
    ${counts}=    Get Incident Latest Events and Alerts Statistics    ${data[0]['id']}
    Should Be Equal As Integers    ${counts['event']}    0
    Should Not Be Equal As Integers    ${counts['alert']}    0

Check Incident Attack Summary
    ${data}=    Search Incident List
    ${result}=    Get Incident IP Relation Data    ${data[0]['id']}
    # Should Not Be Empty    ${result}

Check Incident Details
    ${data}=    Search Incident List    condition=${default_condition}
    ${result}=    Get Incident Details    ${data[0]['id']}
    Should Not Be Empty    ${result}

Check Incident Related Tendency Info
    ${data}=    Search Incident List    condition=${default_condition}
    ${cnt}=    Get Incident Detail Tendency Count    ${data[0]['id']}    day
    Should Not Be Equal As Integers    ${cnt}    0
    ${cnt}=    Get Incident Detail Tendency Count    ${data[0]['id']}    hour
    Should Not Be Equal As Integers    ${cnt}    0

Check Incident Graph
    ${data}=    Search Incident List    condition=${default_condition}
    ${result}=    Get Incident Graph Data    ${data[0]['id']}
    Should Not Be Empty    ${result['links']}
    Should Not Be Empty    ${result['nodes']}

Check Incident Sankey Diagram
    ${data}=    Search Incident List    condition=${default_condition}
    ${merge_alert}=    Get Incident Details    ${data[0]['id']}
    ${result}=    Get Incident Sankey Diagram Data    ${merge_alert[0]['id']}
    Should Not Be Empty    ${result['links']}
    Should Not Be Empty    ${result['nodes']}

Delete One Merged Alert
    ${data}=    Search Incident List
    ${merge_alert}=    Get Incident Details    ${data[0]['id']}
    Delete Merged Alert From Incident    ${merge_alert[0]['id']}

Update Incident
    ${update_value}    Set Variable    test advice
    ${data}=    Search Incident List
    Update Incident With Fileds    ${data[0]['id']}    advice=${update_value}
    ${result}=    Get Incident Basic Info    ${data[0]['id']}
    Should Be Equal As Strings    ${result['advice']}    ${update_value}

Check Incident Rules And Types
    ${rules}=    Get All Incident Rules
    ${types}=    Get All Incident Rule Types
    Should Not Be Empty    ${rules}
    Should Not Be Empty    ${types}

Check ALL Attck Info
    ${attck}=    Get Mapping Attack List
    Should Not Be Empty    ${attck}
    ${data}=    Get Attck List
    Should Not Be Empty    ${data}
    :FOR    ${item}    IN    @{data}
    \    Check Tech Basic Info    ${item}

*** Keywords ***
Incident Test Setup
    User Login    ${default_username}    ${default_password}

Incident Test Teardown
    No Operation

Check Tech Basic Info
   [Arguments]    ${item}
   :FOR    ${tech}    IN    @{item['items']}
   \    ${ids}=    Split String    ${tech['id']}    _
   \    ${data}=   Get Attck Tech Info    ${ids[1]}
   \    Should Not Be Empty    ${data['name']}
   \    Should Not Be Empty    ${data['description']}
   \    Should Not Be Empty    ${data['relations']}
   \    Should Not Be Empty    ${data['id']}