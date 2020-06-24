*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Register to TIP
    [Arguments]    ${ip}    ${port}    ${key}    ${sslenabled}=1
    Module Exec    TIP    register    ip=${ip}    port=${port}    key=${key}    sslenabled=${sslenabled}

Unregister from TIP
    Module Exec    TIP    unregister

Get APIKey from TIP
    [Arguments]    ${ip}
    ${key}    Module Exec    TIP    get_apikey_from_tip    tip_ip=${ip}
    [Return]    ${key}