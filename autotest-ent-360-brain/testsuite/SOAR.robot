*** Settings ***
Test Setup        SOAR Test Setup
Test Teardown     SOAR Test Teardown
Resource          kw_ent.robot
Resource          kw_soar.robot
Resource          kw_sys_cfg.robot
Resource          kw_cep.robot
Resource          kw_user.robot
Library           String

*** Variables ***


*** Test Cases ***
Create New Automation
    @{tags}    Create List    test    abc
    ${id}=    Create Automation Action    name=automation    tags=@{tags}
    Should Not Be Empty    ${id}
    Run Keyword and Expect Error    *    Create Automation Action    name=automation

Delete Automation
    ${id}=    Create Automation Action    name=automation_delete
    Delete Automation Action    ${id}
    ${automation}=    Search Automation Action    name=automation_delete
    Should Be Empty    ${automation}

Check Automation Tags
    @{tags}    Create List    test    abc
    ${id}=    Create Automation Action    name=automation    tags=@{tags}
    ${tag}=    Get All Automation Tags
    Length Should Be    ${tag}    2
    Delete Automation Action    ${id}
    ${tag}=    Get All Automation Tags
    Should Be Empty    ${tag}

Search Automation with name or tag
    @{tags}    Create List    test    abc
    ${id1}=    Create Automation Action    name=automation_1    tags=@{tags}
    ${id2}=    Create Automation Action    name=automation_2
    ${automation}=    Search Automation Action    name=automation_1
    Length Should Be    ${automation}    1
    ${automation}=    Search Automation Action    tag=test
    Length Should Be    ${automation}    1
    ${automation}=    Search Automation Action    name=automation
    Length Should Be    ${automation}    2

Creat New Playbook
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${playbook}=    Create Playbook    name=test    action=${automation}
    Should Not Be Empty    ${playbook}
    Run Keyword and Expect Error    *    Create Playbook    name=test    action=${automation}

Search Playbook with name or tag
    @{tags}    Create List    ABC    new
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${id1}=    Create Playbook    name=test_p1    action=${automation}    tags=@{tags}
    ${id2}=    Create Playbook    name=test_p2    action=${automation}
    ${tag}=    Get All Playbook Tags
    Length Should Be    ${tag}    2
    ${playbook}=    Search Playbook    name=p1
    Length Should Be    ${playbook}    1
    ${playbook}=    Search Playbook    tag=ABC
    Length Should Be    ${playbook}    1
    Delete Playbook    ${id1}
    ${tag}=    Get All Playbook Tags
    Should Be Empty    ${tag}
    Run Keyword and Expect Error    *    Delete Automation Action    ${id}

Create Manual Action in Playbook
    ${action}=    Create Default Manual Action
    ${id}=    Create Playbook    name=test_manaul    action=${action}
    ${actions}=    Search Manual Action
    Should Not Be Empty    ${actions}
    Delete Playbook    ${id}
    ${actions}=    Search Manual Action
    Should Be Empty    ${actions}

Run Playbook
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${playbook}=    Create Playbook    name=test    action=${automation}
    Trigger Playbook    ${playbook}
    Wait Until Case Running

Delete CaseManage
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${playbook}=    Create Playbook    name=test    action=${automation}
    Trigger Playbook    ${playbook}
    Wait Until Case Running
    ${casemanage}    Get All CaseManage
    Delete CaseManage    ${casemanage[0]['_id']}
    ${casemanage}    Get All CaseManage
    Should Be Empty    ${casemanage}

Search CaseManage
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${playbook}=    Create Playbook    name=test_search    action=${automation}
    Trigger Playbook    ${playbook}
    Wait Until Case Running
    ${case}=    Search CaseManage    名称 = 'test_search'
    Should Not Be Empty    ${case}

Check CaseManage Details
    ${id}=    Create Automation Action    name=automation
    ${automation}=    Get Automation Action Detail    ${id}
    ${playbook}=    Create Playbook    name=test    action=${automation}
    Trigger Playbook    ${playbook}
    Wait Until Case Running
    ${casemanage}    Get All CaseManage
    ${case_id}    set variable    ${casemanage[0]['_id']}
    ${case_detail}    Get CaseManage Detail    ${case_id}
    should be equal    ${case_id}    ${case_detail['_id']}

Check CaseManage Task List
    ${action}=    Create Default Manual Action
    ${id}=    Create Playbook    name=test_manaul    action=${action}
    Trigger Playbook    ${id}
    Wait Until Case Running
    ${casemanage}    Get All CaseManage
    ${case_id}    set variable    ${casemanage[0]['_id']}
    Sleep  5
    ${case_tasklist}    Get Task List    ${case_id}
    Should Not Be Empty    ${case_tasklist}
    ${actionStatus}    set variable    ${case_tasklist[0]['actionStatus']}
    Should Be Equal As Integers    ${0}    ${actionStatus}


*** Keywords ***
SOAR Test Setup
    User Login    ${default_username}    ${default_password}

SOAR Test Teardown
    Delete All CaseManage
    Delete All Playbook
    Delete All Automation

Running Case Should Not Be Empty
    ${casemanage}    Get All CaseManage
    Should Not Be Empty    ${casemanage}

Wait Until Case Running
    Wait Until Keyword Succeeds    30s    2s    Running Case Should Not Be Empty