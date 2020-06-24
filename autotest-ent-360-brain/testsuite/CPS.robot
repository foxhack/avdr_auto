*** Settings ***
Documentation     Test for CPS AU update
Test Setup        TestSetup
Test Teardown     TestTeardown
Resource          kw_ent.robot

*** Variables ***
${local_au_server}    http://x.x.x.x:xx/api/cps/check-update
${official_au_server}    https://cps.hansight.com/api/cps/check-update
${module_id_ti}    1fd1d830-ab6d-449a-84fc-144331c124d7
${module_id_nta}    77819477-ba9b-482a-8d47-b9be5d55cbe3
${module_id_2k4k}    d6bdf16e-fcea-4b28-89b9-c9d2e288a623
${module_id_event_parser}    23dca495-0ff9-4939-b430-e2a3a46aa82c
${module_id_cep}    cedba6f9-8959-4543-b0d1-070433a39b05
${check_timeout}    90
${check_interval}    5


*** Test Cases ***
UI can query update log
    Modify and Trigger AU Schedule Timely
    Sleep    60
    @{log}=    Module Exec    AuditLog    query_update_log
    ${log_cnt}=    Evaluate    len(@{log})
    # Should Not Be Equal As Integers    ${log_cnt}    0

*** Keywords ***
TestSetup
    User Login    ${default_username}    ${default_password}

TestTeardown
    Reset AU Schedule to Default
    User Logout

Modify and Trigger AU Schedule Timely
    ${sql}=    Set Variable    update JOB_DATA set JOB_CRON_EXPRESSION='*/5 * * * * ?' where JOB_ID=5
    Execute Mysql Cmd    ${sql}

Reset AU Schedule to Default
    ${sql}=    Set Variable    update JOB_DATA set JOB_CRON_EXPRESSION='0 52 5 * * ?' where JOB_ID=5
    Execute Mysql Cmd    ${sql}

Set AU Server Source
    [Arguments]    ${server}
    ${cmd}=    Set Variable    sed -i 's%"url".*check-update.*%"url":"${server}"%' /opt/hansight/misc/cpsclient/cps.json
    Execute SSH Cmd    ${cmd}
    ${cmd}=    Set Variable    sed -i 's/"sslEnable":true/"sslEnable":false/' /opt/hansight/misc/cpsclient/cps.json
    Execute SSH Cmd    ${cmd}
    ${cmd}=    Set Variable    /opt/hansight/hanctl restart misc
    Execute SSH Cmd    ${cmd}

Check module file can be updated
    [Arguments]    ${module_id}
    ${sql}=    Set Variable    select count(*) from active_update_audit where module_id='${module_id}'
    ${count}=    Execute Mysql Cmd    ${sql}
    Should Not Be Equal As Integers    ${count}    0

Wait until module package can be updated
    [Arguments]    ${module_id}
    Wait Until Keyword Succeeds    ${check_timeout}    ${check_interval}    Check module file can be updated    ${module_id_ti}