*** Settings ***
Documentation     NTA Test for Hansight Enterprise
Suite Setup       NTA Suite Setup
Suite Teardown    NTA Suite Teardown
Test Setup        Case Setup Default User Login
Resource          kw_ent.robot
Resource          kw_sys_cfg.robot
Resource          kw_role.robot
Resource          kw_user.robot
Resource          kw_event.robot
Resource          kw_asset.robot
Resource          kw_cep.robot
Resource          kw_report.robot
Resource          kw_dataviewer.robot
Resource          kw_utils.robot
Resource          kw_notify.robot
Resource          kw_vulnerability.robot
Resource          kw_alarm.robot
Resource          kw_ldap_user.robot
Resource          kw_history_task.robot
Resource          kw_ti.robot
Resource          kw_nta.robot

*** Variables ***

*** Test Cases ***
Query NTA
    ${parameter_def}    Set Variable    (事件名称 = \"web访问\") AND (解析规则名称 = \"nta_dispatcher\")
    Query NTA    parameter_def=${parameter_def}

Query NTA by Parameter
    ${parameter_def}    Set Variable    (事件名称 = \"web访问\") AND (解析规则名称 = \"nta_dispatcher\")
    ${parameter}    Set Variable    (域名 = \"morningcircle.net\")
    Query NTA    parameter_def=${parameter_def}    parameter=${parameter}

Config NTA Add White IP IPV4
    ${desc}    Set Variable    test_ipv4白名单IP
    ${ip}    Set Variable    127.0.0.1
    ${type}    Set Variable    1
    ${ipType}    Set Variable    1
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV4
    ${type}    Set Variable    1
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Add White IP IPV6
    ${desc}    Set Variable    test_ipv6白名单IP
    ${ip}    Set Variable    2001:0d02:0000:0000:0014:0000:0000:0095
    ${type}    Set Variable    1
    ${ipType}    Set Variable    2
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV6
    ${type}    Set Variable    1
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Enable IP White list
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    1
    ${ipFilterType}    Set Variable    1
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config Flow Collection IP BlackList
    ${desc}    Set Variable    b.hiphotos.baidu.com
    ${ip}    Set Variable    58.216.55.48
    ${type}    Set Variable    2
    ${ipType}    Set Variable    1
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    1
    ${ipFilterType}    Set Variable    2
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.
    ${parameter_def}    Set Variable    (事件名称 = \"web访问\" or 事件名称 = \"Web access\") AND (解析规则名称 = \"nta_dispatcher\")
    ${parameter}    Set Variable    (域名 = \"b.hiphotos.baidu.com\")
    ${rsp}=    Query NTA_RSP_TOTAL    parameter_def=${parameter_def}    parameter=${parameter}
    Should Not Be Equal As Integers    ${rsp}    0
    ${type}    Set Variable    2
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Add Black IP IPV4
    ${desc}    Set Variable    test_ipv4黑名单IP
    ${ip}    Set Variable    127.0.0.1
    ${type}    Set Variable    2
    ${ipType}    Set Variable    1
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete Black IP IPV4
    ${type}    Set Variable    2
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Add Black IP IPV6
    ${desc}    Set Variable    test_ipv6黑名单IP
    ${ip}    Set Variable    2001:0d02:0000:0000:0014:0000:0000:0095
    ${type}    Set Variable    2
    ${ipType}    Set Variable    2
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete Black IP IPV6
    ${type}    Set Variable    2
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Enable IP Black list
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    1
    ${ipFilterType}    Set Variable    2
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add White PORT
    ${desc}    Set Variable    test_https_443
    ${port}    Set Variable    443
    ${type}    Set Variable    1
    Add NTA PORT    desc=${desc}    port=${port}    type=${type}

Config NTA Delete White PORT
    ${type}    Set Variable    1
    ${id}=    List NTA PORT    type=${type}
    Delete NTA PORT    id=${id}

Config NTA Enable PROT White list
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    1
    ${portFilterType}    Set Variable    1
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add Black PORT
    ${desc}    Set Variable    test_https_443
    ${port}    Set Variable    443
    ${type}    Set Variable    2
    Add NTA PORT    desc=${desc}    port=${port}    type=${type}

Config NTA Delete Black PORT
    ${type}    Set Variable    2
    ${id}=    List NTA PORT    type=${type}
    Delete NTA PORT    id=${id}

Config NTA Enable PROT Black list
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    1
    ${portFilterType}    Set Variable    2
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Enable alertEnable
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    1
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Enable alertPcapExtract
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    1
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Enable aiWeb
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    1
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add White IP IPV4 for file store
    ${desc}    Set Variable    test_ipv4白名单IP
    ${ip}    Set Variable    127.0.0.1
    ${type}    Set Variable    3
    ${ipType}    Set Variable    1
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV4 for file store
    ${type}    Set Variable    3
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Add White IP IPV6 for file store
    ${desc}    Set Variable    test_ipv6白名单IP
    ${ip}    Set Variable    2001:0d02:0000:0000:0014:0000:0000:0095
    ${type}    Set Variable    3
    ${ipType}    Set Variable    2
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV6 for file store
    ${type}    Set Variable    3
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Enable White IP for File Store
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    1
    ${fileStoreIpFilter}    Set Variable    1
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add White Postfix
    ${desc}    Set Variable    test_白名单文件后缀
    ${postfix}    Set Variable    exe
    ${type}    Set Variable    1
    Add NTA POSTFIX    desc=${desc}    postfix=${postfix}    type=${type}

Config NTA Delete White Postfix
    ${type}    Set Variable    1
    ${id}=    List NTA POSTFIX    type=${type}
    Delete NTA POSTFIX    id=${id}

Config NTA Enable White Postfix for File Store
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    1
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    1
    ${filePostfixFilterType}    Set Variable    1
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add Black Postfix
    ${desc}    Set Variable    test_黑名单文件后缀
    ${postfix}    Set Variable    jpg
    ${type}    Set Variable    2
    Add NTA POSTFIX    desc=${desc}    postfix=${postfix}    type=${type}

Config NTA Delete Black Postfix
    ${type}    Set Variable    2
    ${id}=    List NTA POSTFIX    type=${type}
    Delete NTA POSTFIX    id=${id}

Config NTA Enable Black Postfix for File Store
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    1
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    1
    ${filePostfixFilterType}    Set Variable    2
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add White IP IPV4 for pcap store
    ${desc}    Set Variable    test_ipv4白名单IP
    ${ip}    Set Variable    127.0.0.1
    ${type}    Set Variable    4
    ${ipType}    Set Variable    1
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV4 for pcap store
    ${type}    Set Variable    4
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Add White IP IPV6 for pcap store
    ${desc}    Set Variable    test_ipv6白名单IP
    ${ip}    Set Variable    2001:0d02:0000:0000:0014:0000:0000:0095
    ${type}    Set Variable    4
    ${ipType}    Set Variable    2
    Add NTA IP    desc=${desc}    ip=${ip}    type=${type}    ipType=${ipType}

Config NTA Delete White IP IPV6 for pcap store
    ${type}    Set Variable    4
    ${id}=    List NTA IP    type=${type}
    Delete NTA IP    id=${id}

Config NTA Enable White IP for pcap store
    ${pcapStore}    Set Variable    1
    ${pcapStoreIpFilter}    Set Variable    1
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Add White PORT for pcap store
    ${desc}    Set Variable    test_https_443
    ${port}    Set Variable    443
    ${type}    Set Variable    3
    Add NTA PORT    desc=${desc}    port=${port}    type=${type}

Config NTA Delete White PORT for pcap store
    ${type}    Set Variable    3
    ${id}=    List NTA PORT    type=${type}
    Delete NTA PORT    id=${id}

Config NTA Enable PROT White for pcap store
    ${pcapStore}    Set Variable    1
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    1
    ${fileStore}    Set Variable    0
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.

Config NTA Enable file Store
    ${pcapStore}    Set Variable    0
    ${pcapStoreIpFilter}    Set Variable    0
    ${pcapStorePortFilter}    Set Variable    0
    ${fileStore}    Set Variable    1
    ${fileStoreIpFilter}    Set Variable    0
    ${filePostfixFilter}    Set Variable    0
    ${filePostfixFilterType}    Set Variable    0
    ${ipFilter}    Set Variable    0
    ${ipFilterType}    Set Variable    0
    ${portFilter}    Set Variable    0
    ${portFilterType}    Set Variable    0
    ${alertPcapExtract}    Set Variable    0
    ${alertEnable}    Set Variable    0
    ${aiWeb}    Set Variable    0
    ${msg}=    Config NTA    pcapStore=${pcapStore}    pcapStoreIpFilter=${pcapStoreIpFilter}    pcapStorePortFilter=${pcapStorePortFilter}    fileStore=${fileStore}    fileStoreIpFilter=${fileStoreIpFilter}
    ...    filePostfixFilter=${filePostfixFilter}    filePostfixFilterType=${filePostfixFilterType}    ipFilter=${ipFilter}    ipFilterType=${ipFilterType}    portFilter=${portFilter}    portFilterType=${portFilterType}
    ...    alertPcapExtract=${alertPcapExtract}    alertEnable=${alertEnable}    aiWeb=${aiWeb}
    Should Contain    ${msg}    保存NTA配置成功.
    ${cmd}=    Set Variable    wget http://b.hiphotos.baidu.com/image/pic/item/9825bc315c6034a8ef5250cec5134954082376c9.jpg
    Download FILE    ${cmd}
    Sleep    30
    ${parameter_def}    Set Variable    (事件名称 = \"web访问\" or 事件名称 = \"Web access\") AND (解析规则名称 = \"nta_dispatcher\")
    ${parameter}    Set Variable    (域名 = \"b.hiphotos.baidu.com\")
    ${rsp}=    Query NTA_RSP_STR    parameter_def=${parameter_def}    parameter=${parameter}
    Should Contain    ${rsp}    files

*** Keywords ***
NTA Suite Setup
    No Operation

NTA Suite Teardown
    No Operation

Case Setup Default User Login
    User Login    ${default_username}    ${default_password}
