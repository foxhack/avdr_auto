*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List Time Report
    [Documentation]    list current time report
    ${list_cep_rules}    Module Exec    TimeReport    list
    [Return]    ${list_cep_rules}

Get Time Report
    [Arguments]    ${name}
    [Documentation]    get time report info by report name
    ${report_info}    Module Exec    TimeReport    get_by_name    name=${name}
    [Return]    ${report_info}

Get Time Report By ID
    [Arguments]    ${id}
    [Documentation]    get time report info by report id
    ${report_info}    Module Exec    TimeReport    get    id=${id}
    [Return]    ${report_info}

Add Time Report
    [Arguments]    ${name}=${EMPTY}    ${frequency}=${1}    ${enabled}=${True}    ${mail_enabled}=${False}    ${recipients}=${EMPTY}    ${templates}=${EMPTY}
    ...    &{kwargs}
    ${random_name}    Generate Random Name    time_report_
    ${report_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    Module Exec    TimeReport    create    name=${report_name}    frequency=${frequency}    enabled=${enabled}    mail_enabled=${mail_enabled}
    ...    recipients=${recipients}    templates=${templates}    &{kwargs}
    [Return]    ${report_name}

Delete Time Report
    [Arguments]    ${id}
    [Documentation]    delete time report
    Module Exec    TimeReport    delete    id=${id}

Retrive Time Report
    [Arguments]    ${id}    ${start_time}=${EMPTY}    ${end_time}=${EMPTY}
    [Documentation]    retrive time report
    ${today}    Get Current Date    result_format=%Y-%m-%d
    ${tomorrow}    Get Current Date    increment=1 day    result_format=%Y-%m-%d
    ${start_time}    Set Variable If    '${start_time}'=='${EMPTY}'    ${today}    ${start_time}
    ${end_time}    Set Variable If    '${end_time}'=='${EMPTY}'    ${tomorrow}    ${end_time}
    Module Exec    TimeReport    retrive_report    id=${id}    start_time=${start_time}    end_time=${end_time}

Get Time Report Share Type
    [Arguments]    ${id}
    [Documentation]    get time report share type
    ${share_type}    Module Exec    TimeReport    get_share_type    id=${id}
    [Return]    ${share_type}

Set Time Report Share Type
    [Arguments]    ${id}    ${share_type}    ${users}=${EMPTY}
    [Documentation]    set time report share type
    Module Exec    TimeReport    set_share_type    id=${id}    share_type=${share_type}    users=${users}

List Report Template
    [Documentation]    list current report template
    ${list_cep_rules}    Module Exec    ReportTemplate    list
    [Return]    ${list_cep_rules}

Get Report Template
    [Arguments]    ${name}
    [Documentation]    get report template info by template name
    ${temp_info}    Module Exec    ReportTemplate    get_by_name    name=${name}
    [Return]    ${temp_info}

Get Report Template By ID
    [Arguments]    ${id}
    [Documentation]    get report template info by template name
    ${temp_info}    Module Exec    ReportTemplate    get    id=${id}
    [Return]    ${temp_info}

Create Report Template By File
    [Arguments]    ${file_path}    ${name}=${EMPTY}
    [Documentation]    create report template by file
    ${random_name}    Generate Random Name    report_template_
    ${name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${temp_id}    Module Exec    ReportTemplate    create_by_file    local_file=${file_path}    title=${name}
    [Return]    ${temp_id}

Add New Test Report Template
    [Arguments]    ${name}
    ${random_name}    Generate Random Name    report_template_
    ${name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${temp_id}    Module Exec    ReportTemplate    add_test_template    name=${name}
    [Return]    ${temp_id}

Delete Report Template
    [Arguments]    ${id}
    [Documentation]    delete report template
    Module Exec    ReportTemplate    delete    id=${id}

Get Report Template Share Type
    [Arguments]    ${id}
    [Documentation]    get report template share type
    ${share_type}    Module Exec    ReportTemplate    get_share_type    id=${id}
    [Return]    ${share_type}

Set Report Template Share Type
    [Arguments]    ${id}    ${share_type}    ${users}=${EMPTY}
    [Documentation]    set report template share type
    Module Exec    ReportTemplate    set_share_type    id=${id}    share_type=${share_type}    users=${users}

Config Report Format
    Module Exec    TimeReport    report_format    html,pdf,xlsx

Set Report Format
    [Arguments]    ${format}=${EMPTY}
    Module Exec    TimeReport    report_format    format=${format}

Run Time Report
    [Arguments]    ${id}
    Module Exec    TimeReport    run_report    id=${id}

Check Report
    [Arguments]    ${report_id}    ${template_id}
    ${reportItems_id}    Module Exec    TimeReport    get_reportItem_id    report_id=${report_id}
    ${result}    Module Exec    TimeReport    get_downloads    report_id=${report_id}    template_id=${template_id}    reportItems_id=${reportItems_id}
    [Return]    ${result}