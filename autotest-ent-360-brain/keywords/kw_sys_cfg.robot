*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Get Intranet ID
    [Arguments]    ${name}=${EMPTY}
    ${intranet_info}    Module Exec    Intranet    get_by_name    name=${name}
    [Return]    ${intranet_info['id']}

Update Intranet
    [Arguments]    ${id}=${EMPTY}    ${name}=${EMPTY}    ${longitude}=${EMPTY}    ${latitude}=${EMPTY}    ${intranet}=${EMPTY}
    Module Exec    Intranet    update    id=${id}

Update SMTP
    [Arguments]    ${host}=${EMPTY}    ${port}=${EMPTY}    ${username}=${EMPTY}    ${password}=${EMPTY}
    Module Exec    SMTP    update    host=${host}    port=${port}    username=${username}    password=${password}

Init System Import Module
    [Arguments]    ${local_file}
    Module Exec    InitConfig    import_module    local_file=${local_file}

Init System Export Module
    [Arguments]    ${local_file}    ${args}=${EMPTY}
    log    ${local_file}
    log    ${args}
    Module Exec    InitConfig    export_module    local_file=${local_file}    args=${args}

Get SMTP
    ${smtp_data}    Module Exec    SMTP    get
    [Return]    ${smtp_data}

Get SecurityPolicy
    ${securityPolicy_data}    Module Exec    SecurityPolicy    get
    [Return]    ${securityPolicy_data}

Update SecurityPolicy
    [Arguments]    &{kwargs}
    Module Exec    SecurityPolicy    config    &{kwargs}

Get System Time
    ${system_time}    Module Exec    SystemTime    get_time
    [Return]    ${system_time}

Set System Time
    [Arguments]    ${time}
    Module Exec    SystemTime    set_time    time=${time}

Config LDAP
    [Arguments]    ${bind_dn}    ${password}    ${base_dn}    ${ip}    ${port}    ${ssl_enabled}
    ...    ${ca_file}=${EMPTY}    &{kwargs}
    Module Exec    LdapPolicy    config    bind_dn=${bind_dn}    password=${password}    base_dn=${base_dn}    ip=${ip}
    ...    port=${port}    ssl_enabled=${ssl_enabled}    &{kwargs}

Config Official LDAP Server
    ${bind_dn}    Set Variable    CN=gitlab,OU=NJ,OU=hansight,DC=hansight,DC=com
    ${password}    Set Variable    `:a;oB]3
    ${base_dn}    Set Variable    OU=hansight,DC=hansight,DC=com
    ${ip}    Set Variable    172.16.100.180
    ${port}    Set Variable    ${389}
    ${ssl_enabled}    Set Variable    ${false}
    Config LDAP    ${bind_dn}    ${password}    ${base_dn}    ${ip}    ${port}    ${ssl_enabled}

Update Mantainance
    [Arguments]    &{kwargs}
    Module Exec    Mantainance    config    &{kwargs}

Get Mantainance
    ${config_info}    Module Exec    Mantainance    get
    [Return]    ${config_info}

Run CDT
    Execute SSH Cmd    bash /opt/hansight/enterprise/diagnose/bin/collect_diagnose.sh
    ${result}    Execute SSH Cmd    ls /opt/hansight/enterprise/diagnose/results/
    [Return]    ${result}

Enable Feedback Agent
    [Arguments]    ${status}
    Module Exec    Feedback    enable_feedback    status=${status}

Get Date Range
    [Arguments]    ${start}    ${end}
    @{data}=    Module Exec    Mantainance    generate_datetime_by_days    start=${start}    end=${end}
    [Return]    @{data}

Config Index Storage Days
    [Arguments]    ${name}    ${days}=${EMPTY}
    Module Exec    Mantainance    set_index_keep_days    name=${name}    days=${days}