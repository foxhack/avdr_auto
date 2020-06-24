*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List Menu
    ${list_menus}    Module Exec    Role    get_children_menu_list
    [Return]    ${list_menus}

List Role
    ${list_roles}    Module Exec    Role    list
    [Return]    ${list_roles}

Get Role
    [Arguments]    ${name}
    ${role_info}    Module Exec    Role    get_by_name    name=${name}
    [Return]    ${role_info}

Get Role By ID
    [Arguments]    ${id}
    ${role_info}    Module Exec    Role    get    id=${id}
    [Return]    ${role_info}

Delete Role
    [Arguments]    ${id}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    Role    delete    id=${id}
    ...    ELSE    Module Exec    Role    delete_all

Update Role
    [Arguments]    ${id}    &{kwargs}
    Module Exec    Role    update    id=${id}    &{kwargs}

Add Role
    [Arguments]    ${name}=${EMPTY}    ${description}=${EMPTY}    ${menu}=${EMPTY}
    ${random_name}    Generate Random Name    role_
    ${role_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    Module Exec    Role    create    name=${role_name}    description=${description}    menu=${menu}
    [Return]    ${role_name}

Create Menu List
    [Arguments]    ${allow_type}    @{varargs}
    ${menu}    Create List
    : FOR    ${var}    IN    @{varargs}
    \    ${menu_item}    Generate Menu Dict    ${var}    ${allow_type}
    \    Append To List    ${menu}    ${menu_item}
    [Return]    ${menu}

Get Role ID List
    [Arguments]    @{roles}
    ${ids}    Create List
    : FOR    ${name}    IN    @{roles}
    \    ${role_info}    Get Role    ${name}
    \    ${role_id}    Set Variable    ${role_info['id']}
    \    Append To List    ${ids}    ${role_id}
    [Return]    ${ids}

Add Data Role
    [Arguments]    ${name}=${EMPTY}    ${type}=${EMPTY}    ${content}=${EMPTY}
    ${random_name}    Generate Random Name    data_role_
    ${role_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${role_id}    Module Exec    DataRole    add    name=${role_name}    dtype=${type}    content=${content}
    [Return]    ${role_name}    ${role_id}

Get Data Role
    [Arguments]    ${name}
    ${role_info}    Module Exec    DataRole    get_by_name    name=${name}
    [Return]    ${role_info}

Delete Data Role
    [Arguments]    ${id}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    DataRole    delete    id=${id}
    ...    ELSE    Module Exec    DataRole    delete_all