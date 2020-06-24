*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get All User
    ${list}    Module Exec    LdapUser    getNotSelected_user
    [Return]    ${list}

List LdapUser
    ${ldapUser_list}    Module Exec    LdapUser    ldapUser_list
    [Return]    ${ldapUser_list}

Add LdapUser
    [Arguments]    ${username}
    Module Exec    LdapUser    add_User    username=${username}

Get LdapUser
    [Arguments]    ${name}
    ${LdapUser_info}    Module Exec    LdapUser    get_by_name    name=${name}
    [Return]    ${LdapUser_info}

Update LdapUser
    [Arguments]    ${id}    ${unit_name}=${EMPTY}    ${roles}=${EMPTY}
    Module Exec    LdapUser    update_User    id=${id}    unit_name=${unit_name}    roles=${roles}

Get LdapUser By Id
    [Arguments]    ${id}
    ${LdapUser_info}    Module Exec    LdapUser    get_User    id=${id}
    [Return]    ${LdapUser_info}

Lock LdapUser
    [Arguments]    ${id}
    Module Exec    LdapUser    lock    id=${id}

Unlock LdapUser
    [Arguments]    ${id}
    Module Exec    LdapUser    unlock    id=${id}

Delete LdapUser
    [Arguments]    ${id}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    LdapUser    delete    id=${id}
    ...    ELSE    Module Exec    LdapUser    delete_all
