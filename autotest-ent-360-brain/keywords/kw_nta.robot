*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Query NTA
    [Arguments]    ${parameter_def}=${EMPTY}    ${parameter}=${EMPTY}
    ${rsp}    Module Exec    NTA    query    parameter_def=${parameter_def}    parameter=${parameter}
    [Return]    ${rsp}

Query NTA_RSP_STR
    [Arguments]    ${parameter_def}=${EMPTY}    ${parameter}=${EMPTY}
    ${rsp}    Module Exec    NTA    query_rsp_str    parameter_def=${parameter_def}    parameter=${parameter}
    [Return]    ${rsp}

Query NTA_RSP_TOTAL
    [Arguments]    ${parameter_def}=${EMPTY}    ${parameter}=${EMPTY}
    ${rsp}    Module Exec    NTA    query_rsp_total    parameter_def=${parameter_def}    parameter=${parameter}
    [Return]    ${rsp}

Config NTA
    [Arguments]    ${pcapStore}=${EMPTY}    ${pcapStoreIpFilter}=${EMPTY}    ${pcapStorePortFilter}=${EMPTY}    ${fileStore}=${EMPTY}    ${fileStoreIpFilter}=${EMPTY}    ${filePostfixFilter}=${EMPTY}
    ...    ${filePostfixFilterType}=${EMPTY}    ${ipFilter}=${EMPTY}    ${ipFilterType}=${EMPTY}    ${portFilter}=${EMPTY}    ${portFilterType}=${EMPTY}    ${alertPcapExtract}=${EMPTY}
    ...    ${alertEnable}=${EMPTY}    ${aiWeb}=${EMPTY}
    ${msg}    Module Exec    NTA    config    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}
    ...    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}
    ...    portFilter=${portFilter}    portFilterType=${portFilterType}    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    [Return]    ${msg}

Add NTA IP
    [Arguments]    ${desc}=${EMPTY}    ${ip}=${EMPTY}    ${type}=${EMPTY}    ${ipType}=${EMPTY}
    Module Exec    NTA    add_ip    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

List NTA IP
    [Arguments]    ${type}=${EMPTY}
    ${id}    Module Exec    NTA    list_ip    type=${type}
    [Return]    ${id}

Delete NTA IP
    [Arguments]    ${id}=${EMPTY}
    Module Exec    NTA    delete_ip    id=${id}

Add NTA PORT
    [Arguments]    ${desc}=${EMPTY}    ${port}=${EMPTY}    ${type}=${EMPTY}
    Module Exec    NTA    add_port    desc=${desc}    port=${port}    type=${type}

List NTA PORT
    [Arguments]    ${type}=${EMPTY}
    ${id}    Module Exec    NTA    list_port    type=${type}
    [Return]    ${id}

Delete NTA PORT
    [Arguments]    ${id}=${EMPTY}
    Module Exec    NTA    delete_port    id=${id}

Add NTA POSTFIX
    [Arguments]    ${desc}=${EMPTY}    ${postfix}=${EMPTY}    ${type}=${EMPTY}
    Module Exec    NTA    add_postfix    desc=${desc}    postfix=${postfix}    type=${type}

List NTA POSTFIX
    [Arguments]    ${type}=${EMPTY}
    ${id}    Module Exec    NTA    list_postfix    type=${type}
    [Return]    ${id}

Delete NTA POSTFIX
    [Arguments]    ${id}=${EMPTY}
    Module Exec    NTA    delete_postfix    id=${id}

Download FILE
    [Arguments]    ${cmd}=${EMPTY}
    Execute SSH Cmd    cmd=${cmd}