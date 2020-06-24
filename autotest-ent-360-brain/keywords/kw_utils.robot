*** Settings ***
Variables         ../config/config.py
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           String
Library           PyEnt.utils.HanRandom    WITH NAME    HanRandom
Library           PyEnt    ${console_url}
Library           PyEnt.tool    WITH NAME    Tool
Library           PyEnt.sender.Sender    ${host}    WITH NAME    Sender

*** Keywords ***
Generate Random Name
    [Arguments]    ${prefix}
    ${secs}    Get Time    epoch
    ${secs_str}    Evaluate    str(${secs})
    ${ran}    Evaluate    random.randint(1,100)    random
    ${username}    Catenate    SEPARATOR=    ${prefix}${ran}    ${secs_str[:]}
    [Return]    ${username}

Generate User Email
    [Arguments]    ${username}    ${domain}=${qqmail_domain}
    ${useremail}    Catenate    SEPARATOR=@    ${username}    ${domain}
    [Return]    ${useremail}

Generate Random PhoneNumbers
    ${random_phoneNumbers}    Generate Random String    8    0123456789
    ${phoneNumbers}    Set Variable    182${random_phoneNumbers}
    [Return]    ${phoneNumbers}

Generate Random IP
    ${IP}    HanRandom.IP
    [Return]    ${IP}

Generate Random Port
    ${port}    HanRandom.port
    [Return]    ${port}

Generate Filter Base Condition
    [Arguments]    ${left}    ${middle}    ${right}
    ${filter}    Tool.build_filter_base    ${left}    ${middle}    ${right}
    [Return]    ${filter}

Generate Filter Condition
    [Arguments]    ${op}    ${filter_list}
    ${filter}    Tool.build_filter    ${op}    ${filter_list}
    [Return]    ${filter}

Generate Menu Dict
    [Arguments]    ${id}    ${allow_type}
    ${menu_dict}    Tool.generate_menu_item_dict    ${id}    ${allow_type}
    [Return]    ${menu_dict}

Get Local IP
    ${local_ip}    Sender.get_local_ip
    [Return]    ${local_ip}

Send Data
    [Arguments]    ${content}    ${send_cnt}=${EMPTY}    ${sleep_cnt}=${EMPTY}
    @{count}    Run Keyword If    '${send_cnt}'!='${EMPTY}'    Evaluate    range(${send_cnt})
    ...    ELSE    Create List    1
    : FOR    ${var}    IN    @{count}
    \    ${stat_reg}    Set Variable    stat_time:(\\d{4}-\\d{2}-\\d{2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2})
    \    ${stat_time}    Get Current Date    exclude_millis=yes
    \    ${content}    Replace String Using Regexp    ${content}    ${stat_reg}    stat_time:${stat_time}
    \    Sender.send_string    ${content}
    \    Run Keyword If    '${sleep_cnt}'!='${EMPTY}'    Sleep    ${sleep_cnt}

Query Data
    [Arguments]    ${module}    ${start_time}=${EMPTY}    ${end_time}=${EMPTY}    ${filter_expression}=${EMPTY}
    ${today}    Get Current Date    result_format=%Y-%m-%d
    ${tomorrow}    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    ${start_time}    Set Variable If    '${start_time}'=='${EMPTY}'    ${today}    ${start_time}
    ${end_time}    Set Variable If    '${end_time}'=='${EMPTY}'    ${tomorrow}    ${end_time}
    ${event_list}    Module Exec    ${module}    list    start_time=${start_time}    end_time=${end_time}    filter_expression=${filter_expression}
    ${len}    Get Length    ${event_list}
    [Return]    ${len}

Query And Get Data
    [Arguments]    ${module}    ${start_time}=${EMPTY}    ${end_time}=${EMPTY}    ${filter_expression}=${EMPTY}
    ${today}    Get Current Date    result_format=%Y-%m-%d
    ${tomorrow}    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    ${start_time}    Set Variable If    '${start_time}'=='${EMPTY}'    ${today}    ${start_time}
    ${end_time}    Set Variable If    '${end_time}'=='${EMPTY}'    ${tomorrow}    ${end_time}
    ${event_list}    Module Exec    ${module}    list    start_time=${start_time}    end_time=${end_time}    filter_expression=${filter_expression}
    ${len}    Get Length    ${event_list}
    [Return]    ${len}    ${event_list}

Send File Data
    [Arguments]    ${file}    ${send_cnt}=${EMPTY}    ${sleep_cnt}=${EMPTY}
    @{count}    Run Keyword If    '${send_cnt}'!='${EMPTY}'    Evaluate    range(${send_cnt})
    ...    ELSE    Create List    1
    : FOR    ${var}    IN    @{count}
    \    ${stat_reg}    Set Variable    stat_time:(\\d{4}-\\d{2}-\\d{2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2})
    \    ${stat_time}    Get Current Date    exclude_millis=yes
    \    Sender.send_file    ${file}
    \    Run Keyword If    '${sleep_cnt}'!='${EMPTY}'    Sleep    ${sleep_cnt}

Query Event Logs Count
    [Arguments]    ${Condition}=${EMPTY}
    ${cnt}    Module Exec    Event    query    condition=${Condition}
    [Return]    ${cnt}

Query Alarm Logs Count
    [Arguments]    ${Condition}=${EMPTY}    ${source}=alarm
    ${cnt}    Module Exec    Alarm    query    condition=${Condition}    source=${source}
    [Return]    ${cnt}

Query Asset Logs Count
    [Arguments]    ${Condition}=${EMPTY}
    ${cnt}    Module Exec    Asset    query    condition=${Condition}
    [Return]    ${cnt}

Regex Syslog Src_IP
    [Arguments]    ${str}    ${ip}
    ${reg}    set variable    src:(\\d+.\\d+.\\d+.\\d+)
    ${new_str}    Replace String Using Regexp    ${str}    ${reg}    ${ip}
    [Return]    ${new_str}

Regex Syslog Domain
    [Arguments]    ${str}    ${domain_value}
    ${reg}    set variable    domain:(\\w+.{1,80}\\w+),
    ${new_str}    Replace String Using Regexp    ${str}    ${reg}    ${domain_value},
    [Return]    ${new_str}
