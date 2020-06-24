*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Import License
    [Arguments]    ${localfile}
    Module Exec    License    import_in    localfile=${localfile}

User Login
    [Arguments]    ${username}    ${password}
    login    ${username}    ${password}

User Logout
    logout
