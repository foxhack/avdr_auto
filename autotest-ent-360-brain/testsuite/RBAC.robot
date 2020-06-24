*** Settings ***
Documentation     RBAC Test for Hansight Enterprise
Suite Setup       RBAC Suite Setup
Suite Teardown    RBAC Suite Teardown
Test Setup        RBAC Test Setup
Test Teardown     RBAC Test Teardown
Variables         ../config/rbac_variable.py
Resource          kw_ent.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_utils.robot
Resource          kw_ldap_user.robot
Resource          kw_sys_cfg.robot

*** Test Cases ***
Admin Role Check
    Default User Login
    ${user}    Get Login User
    Should Be Equal As Strings    ${user['username']}    admin

Add Invalid Role Check
    Default User Login
    ${menu}    Create List
    Run Keyword and Expect Error    *    Add Role    menu=${menu}
    ${menu}    Create Menu List    ${rbac_allow_type_rw}    @{rbac_allow_menu}
    Run Keyword and Expect Error    *    Add Role    name=${buildin_role_name}    menu=${menu}

Add Valid Role Check
    Default User Login
    ${menu}    Create Menu List    ${rbac_allow_type_rw}    @{rbac_allow_menu}
    ${role_name}    Add Role    name=${valid_role_name}    menu=${menu}
    ${role_info}    Get Role    ${role_name}
    ${role_id}    Set Variable    ${role_info['id']}
    Delete Role    ${role_id}

Update Role Check
    Default User Login
    ${role_info}    Get Role    ${update_role_name}
    ${role_id}    Set Variable    ${role_info['id']}
    Run Keyword and Expect Error    *    Update Role    ${role_id}    menus=[]
    Update Role    ${role_id}    description=${update_message}

Change Admin Pwd Check
    Default User Login
    Run Keyword and Expect Error    *    Change User Password    ${suggest_password}    ${suggest_password}
    Change User Password    ${default_password}    ${suggest_password}
    user login    ${default_username}    ${suggest_password}
    Change User Password    ${suggest_password}    ${default_password}
    user login    ${default_username}    ${default_password}

Update Admin Check
    Default User Login
    ${admin_info}    Get User    ${default_username}
    Log    ${admin_info['id']}
    Update User    ${admin_info['id']}

Lock And Unlock Admin Check
    Default User Login
    ${admin_info}    Get User    ${default_username}
    Run Keyword and Expect Error    *    Lock User    ${admin_info['id']}
    ${passed} =    Run Keyword And Return Status    Unlock User    ${admin_info['id']}

Delete Admin Check
    Default User Login
    ${admin_info}    Get User    ${default_username}
    Delete User    ${admin_info['id']}
    User Logout
    Default User Login

Add Invalid User Check
    Default User Login
    ${roles}    Create List
    Run Keyword and Expect Error    *    Add User    password=${suggest_password}    roles=${roles}
    Append To List    ${roles}    ${buildin_role_name}
    Run Keyword and Expect Error    *    Add User    login_name=${default_username}    password=${suggest_password}    roles=${roles}
    Run Keyword and Ignore Error    Add User    login_name=${invalid_user_name}    password=${suggest_password}    roles=${roles}

Add User With One Role Check
    Default User Login
    Sleep    1
    ${menu}    Create Menu List    ${rbac_allow_type_rw}    @{rbac_allow_menu}
    ${role_name}    Add Role    menu=${menu}
    ${roles}    Create List    ${role_name}
    ${role_ids}    Get Role ID List    @{roles}
    ${status}    ${userinfo}    Run Keyword And Ignore Error    Get User    ${valid_user_name}
    Run Keyword If    '${status}' == 'PASS'    Delete User    ${userinfo['id']}
    User Login Info Check    ${roles}    ${role_ids}    ${menu}

Add User With NonCross Role Check
    Default User Login
    Sleep    1
    ${menu_a}    Create Menu List    ${rbac_allow_type_rw}    @{rbac_allow_menu}
    ${menu_b}    Create Menu List    ${rbac_allow_type_r}    @{rbac_allow_menu_2}
    ${menu}    Combine Lists    ${menu_a}    ${menu_b}
    ${role_name_a}    Add Role    menu=${menu_a}
    Sleep    1
    ${role_name_b}    Add Role    menu=${menu_b}
    ${roles}    Create List    ${role_name_a}    ${role_name_b}
    ${role_ids}    Get Role ID List    @{roles}
    ${status}    ${userinfo}    Run Keyword And Ignore Error    Get User    ${valid_user_name}
    Run Keyword If    '${status}' == 'PASS'    Delete User    ${userinfo['id']}
    # User Login Info Check    ${roles}    ${role_ids}    ${menu}

Add User With Cross Role Check
    Default User Login
    Sleep    1
    ${menu_a}    Create Menu List    ${rbac_allow_type_r}    @{rbac_allow_menu}
    ${menu_b}    Create Menu List    ${rbac_allow_type_rw}    @{rbac_allow_menu}
    ${menu}    Combine Lists    ${menu_a}    ${menu_b}
    ${role_name_a}    Add Role    menu=${menu_a}
    Sleep    1
    ${role_name_b}    Add Role    menu=${menu_b}
    ${roles}    Create List    ${role_name_a}    ${role_name_b}
    ${role_ids}    Get Role ID List    @{roles}
    ${status}    ${userinfo}    Run Keyword And Ignore Error    Get User    ${valid_user_name}
    Run Keyword If    '${status}' == 'PASS'    Delete User    ${userinfo['id']}
    User Login Info Check    ${roles}    ${role_ids}    ${menu_b}

User Function Check
    Default User Login
    ${roles}    Create List    ${buildin_role_name}
    ${user_name}    Add User    password=${default_password}    roles=${roles}
    User Logout
    user login    ${user_name}    ${default_password}
    ${login_user}    Get Login User
    ${user_id}    Set Variable    ${login_user['id']}
    Log    Test\ Change\ Password
    Run Keyword and Expect Error    *    Change User Password    ${suggest_password}    ${default_password}
    Change User Password    ${default_password}    ${suggest_password}
    user login    ${user_name}    ${suggest_password}
    Log    Test\ Update\ User
    Update User    ${user_id}
    User Logout
    Log    Test\ Lock\ And Unlock\ User
    Default User Login
    Lock User    ${user_id}
    Run Keyword and Expect Error    *    user login    ${user_name}    ${suggest_password}
    Default User Login
    Unlock User    ${user_id}
    user login    ${user_name}    ${suggest_password}
    User Logout
    Default User Login
    Delete User    ${user_id}

LdapUser Function Check
    Default User Login
    Config Official LDAP Server
    ${list}    Get All User
    Add LdapUser    ${list[0]['loginName']}
    ${user_info}    Get LdapUser    ${list[0]['loginName']}
    ${roles}    create list    系统管理员
    Update LdapUser    ${user_info['id']}    unit_name=组织机构    roles=${roles}
    ${update_userInfo}    Get LdapUser By Id    ${user_info['id']}
    Should Not Be Empty    ${update_userInfo['roles']}
    Should Not Be Empty    ${update_userInfo['systemUnit']}
    Delete LdapUser
    ${user_list}    List LdapUser
    Should Be Empty    ${user_list}

*** Keywords ***
RBAC Suite Setup
    No Operation

RBAC Suite Teardown
    No Operation

RBAC Test Setup
    No Operation

RBAC Test Teardown
    No Operation

Default User Login
    [Documentation]    admin user login
    User Login    ${default_username}    ${default_password}

Default User Logout
    [Documentation]    admin user logout
    User Logout

User Login Info Check
    [Arguments]    ${roles}    ${role_ids}    ${menu}
    Add User    login_name=${valid_user_name}    password=${suggest_password}    roles=${roles}
    User Logout
    user login    ${valid_user_name}    ${suggest_password}
    ${login_user}    Get Login User
    ${login_menu}    Get Login Menu
    ${user_id}    Set Variable    ${login_user['id']}
    List Should Contain Sub List    ${login_menu}    ${menu}
    # List Should Contain Sub List    ${menu}    ${login_menu}
    Should Be Equal    ${login_user['username']}    ${valid_user_name}
    Default User Login
    : FOR    ${role_id}    IN    @{role_ids}
    \    Run Keyword and Expect Error    *    Delete Role    ${role_id}
    Delete User    ${user_id}
    : FOR    ${role_id}    IN    @{role_ids}
    \    Delete Role    ${role_id}
    Run Keyword and Expect Error    *    user login    ${valid_user_name}    ${default_password}
