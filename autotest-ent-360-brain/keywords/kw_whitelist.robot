*** Settings ***
Variables         ../config/config.py
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           String
Library           PyEnt    ${console_url}

*** Keywords ***
Get global-whitelist
    ${list}    Module Exec    GlobalWhitelist    list
    [Return]    ${list}

Get globalwhitelist by id
    [Arguments]   ${id}
    ${list}    Module Exec    GlobalWhitelist    get_by_id    ${id}
    [Return]    ${list}

Add Global Whitelist Value
    [Arguments]    &{data}
    Module Exec    GlobalWhitelist    create_by_data    &{data}

Delete All Global-whitelist
    Module Exec    GlobalWhitelist    delete_all

Query Global Whitelist
    [Arguments]    ${content}
    ${list}    Module Exec    GlobalWhitelist    query_by_content    content=${content}
    [Return]    ${list}

Modify Global Whitelist
    [Arguments]    ${id}    ${content}
    Module Exec    GlobalWhitelist    update_globalwhitelist    id=${id}    content=${content}

Import Global Whitelist
    [Arguments]    ${local_file}
    Module Exec    GlobalWhitelist    import_global_whitelist_file    local_file=${local_file}

Export Global Whitelist By ID
    [Arguments]    ${local_file}    ${id}
    Module Exec    GlobalWhitelist    export_global_whitelist_file    local_file=${local_file}    id=${id}

Export All Global Whitelist
    [Arguments]    ${local_file}
    Module Exec    GlobalWhitelist    export    local_file=${local_file}

Get Ioc-whitelist
    ${list}    Module Exec    IntelligenceWhitelist    list
    [Return]    ${list}

Add Ioc Whitelist Value
    [Arguments]    &{data}
    Module Exec    IntelligenceWhitelist    create_iocwhitelist_by_data    &{data}

Add Ioc Whitelist By File
    [Arguments]    ${file}
    Module Exec    IntelligenceWhitelist    create_iocwhitelist_by_file    file=${file}

Delete All Ioc-whitelist
    Module Exec    IntelligenceWhitelist    delete_all

Query Ioc Whitelist
    [Arguments]    ${content}
    ${list}    Module Exec    IntelligenceWhitelist    query_by_content    content=${content}
    [Return]    ${list}

Modify Ioc Whitelist
    [Arguments]    ${id}    ${content}
    Module Exec    IntelligenceWhitelist    update_iocwhitelist    id=${id}    content=${content}

Import Intelligence Whitelist
    [Arguments]    ${local_file}
    Module Exec    IntelligenceWhitelist    import_intelligence_whitelist_file    local_file=${local_file}

Export Intelligence Whitelist By ID
    [Arguments]    ${local_file}    ${id}
    Module Exec    IntelligenceWhitelist    export_intelligence_whitelist_file    local_file=${local_file}    id=${id}

Export All Intelligence Whitelist
    [Arguments]    ${local_file}
    Module Exec    IntelligenceWhitelist    export    local_file=${local_file}