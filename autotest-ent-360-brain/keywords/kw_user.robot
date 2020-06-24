*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get Login User
    ${user_info}    Module Exec    User    get_login_user
    [Return]    ${user_info}

Get Login Menu
    ${list_menus}    Module Exec    User    get_login_menu
    [Return]    ${list_menus}

List User
    ${list_users}    Module Exec    User    list
    [Return]    ${list_users}

Get User
    [Arguments]    ${name}
    ${user_info}    Module Exec    User    get_by_name    name=${name}
    [Return]    ${user_info}

Get User By ID
    [Arguments]    ${id}
    ${user_info}    Module Exec    User    get    id=${id}
    [Return]    ${user_info}

Delete User
    [Arguments]    ${id}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    User    delete    id=${id}
    ...    ELSE    Module Exec    User    delete_all

Update User
    [Arguments]    ${id}    &{kwargs}
    Module Exec    User    update    id=${id}    &{kwargs}

Add User
    [Arguments]    ${login_name}=${EMPTY}    ${real_name}=${EMPTY}    ${password}=${suggest_password}    ${unit_name}=组织机构    ${email}=${EMPTY}    ${mobile}=${EMPTY}
    ...    ${roles}=@{EMPTY}    ${data_roles}=@{EMPTY}
    ${random_loginname}    Generate Random Name    user_
    ${login_name}    Set Variable If    '${login_name}'=='${EMPTY}'    ${random_loginname}    ${login_name}
    ${real_name}    Set Variable If    '${real_name}'=='${EMPTY}'    ${login_name}    ${real_name}
    ${password}    Set Variable If    '${password}'=='${EMPTY}'    ${suggest_password}    ${password}
    Module Exec    User    create    login_name=${login_name}    real_name=${real_name}    password=${password}    unit_name=${unit_name}
    ...    email=${email}    mobile=${mobile}    roles=${roles}    data_roles=${data_roles}
    [Return]    ${login_name}

Lock User
    [Arguments]    ${id}
    Module Exec    User    lock    id=${id}

Unlock User
    [Arguments]    ${id}
    Module Exec    User    unlock    id=${id}

Change User Password
    [Arguments]    ${old_pwd}    ${new_pwd}
    Module Exec    User    change_pwd    old_pwd=${old_pwd}    new_pwd=${new_pwd}
