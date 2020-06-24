*** Settings ***
Resource          kw_utils.robot

*** Variables ***


*** Keywords ***
Create Automation Action
    [Arguments]    ${name}    ${tags}=${EMPTY}    ${is_condition}=${false}
    ${id}=    Module Exec    Automation    create    name=${name}    tags=${tags}    is_condition=${is_condition}
    [Return]    ${id}

Search Automation Action
    [Arguments]    ${name}=${EMPTY}    ${tag}=${EMPTY}
    ${data}=    Module Exec    Automation    search    name=${name}    tag=${tag}
    [Return]    ${data}

Get All Automation Tags
    ${data}=    Module Exec    Automation    get_all_tags
    [Return]    ${data}

Delete Automation Action
    [Arguments]    ${id}
    Module Exec    Automation    delete    auto_id=${id}

Delete All Automation
    Module Exec    Automation    delete_all

Get Automation Action Detail
    [Arguments]    ${id}
    ${data}=    Module Exec    Automation    get_detail    auto_id=${id}
    [Return]    ${data}

Create Playbook
    [Arguments]    ${name}    ${action}    ${tags}=${EMPTY}
    ${id}=    Module Exec    Playbook    create    name=${name}    action=${action}    tags=${tags}
    [Return]    ${id}

Search Playbook
    [Arguments]    ${name}=${EMPTY}    ${tag}=${EMPTY}
    ${data}=    Module Exec    Playbook    search    name=${name}    tag=${tag}
    [Return]    ${data}

Get All Playbook Tags
    ${data}=    Module Exec    Playbook    get_all_tags
    [Return]    ${data}

Delete Playbook
    [Arguments]    ${id}
    Module Exec    Playbook    delete    playbook_id=${id}

Delete All Playbook
    Module Exec    Playbook    delete_all

Get Playbook Detail
    [Arguments]    ${id}
    ${data}=    Module Exec    Playbook    get_detail    auto_id=${id}
    [Return]    ${data}

Create Default Manual Action
    ${data}=    Module Exec    Playbook    create_manual_action
    [Return]    ${data}

Search Manual Action
    ${data}=    Module Exec    Playbook    get_manual_action
    [Return]    ${data}

Trigger Playbook
    [Arguments]    ${id}
    Module Exec    Playbook    trigger    playbook_id=${id}

Get All CaseManage
    ${data}    Module Exec    CaseManage    search
    [Return]    ${data}

Search CaseManage
    [Arguments]    ${filters}
    ${data}    Module Exec    CaseManage    search    filters=${filters}
    [Return]    ${data}

Get CaseManage Detail
    [Arguments]    ${id}
    ${data}    Module Exec    CaseManage    get_detail    case_id=${id}
    [Return]    ${data}

Get Task List
    [Arguments]    ${id}
    ${data}    Module Exec    CaseManage    get_task_list    case_id=${id}
    [Return]    ${data}

Delete CaseManage
    [Arguments]    ${id}
    Module Exec    CaseManage    delete    case_id=${id}

Delete All CaseManage
    Module Exec    CaseManage    delete_all