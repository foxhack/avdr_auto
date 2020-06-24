*** Settings ***
Variables         ../config/config.py
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           String    #Library    PyEnt    ${console_url}

*** Keywords ***
Check module file can be updated
    [Arguments]    ${module_id}
    ${sql}=    Set Variable    select count(*) from active_update_audit where module_id='${module_id}'
    ${count}=    Execute Mysql Cmd    ${sql}
    Should Not Be Equal As Integers    ${count}    0

Wait until module package can be updated
    [Arguments]    ${module_id}
    Wait Until Keyword Succeeds    90    5    Check module file can be updated    ${module_id_ti}

Get Threat Ioc
    ${ioc_ip}    Module Exec    Elasticsearch    get_valid_ioc    type=ip
    [Return]    ${ioc_ip}

Get Threat Ioc-domain
    ${ioc_domain}    Module Exec    Elasticsearch    get_valid_ioc    type=domain
    [Return]    ${ioc_domain}

Get ES Ioc Info
    [Arguments]    ${host}    ${ioc}
    ${list}    Module Exec    Elasticsearch    get_ioc_details_from_es    host=${host}    ioc=${ioc}
    [Return]    ${list}

Get Incident of Ioc Details
    [Arguments]    ${ioc}
    ${list}    Module Exec    Incident    get_ice_related_to_ioc    ioc=${ioc}
    [Return]    ${list}

Get Ti Query Status
    ${list}    Module Exec    TiQuery    get_tiquery_status
    [Return]    ${list}

Set Ti Query Configuration
    [Arguments]    ${alarmEnabled}=True    ${eventEnabled}=False
    Module Exec    TiQuery    set_ti_query    alarmEnabled=${alarmEnabled}    eventEnabled=${eventEnabled}

Ti Query Event
    [Arguments]    ${lic_file}    ${ioc}
    ${list}    Module Exec    ThreatIoc    ti_query_event    lic_file=${lic_file}    ioc=${ioc}
    [Return]    ${list}

Ti Query Alarm
    [Arguments]    ${lic_file}    ${ioc}
    ${list}    Module Exec    ThreatIoc    ti_query_alarm    lic_file=${lic_file}    ioc=${ioc}
    [Return]    ${list}

Get Ioc Summary
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    display_threat_summary    ioc=${ioc}
    [Return]    ${list}

Get AlertType Id
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    alerttype_id_details    ioc=${ioc}
    [Return]    ${list}

Get AlertType by Id
    [Arguments]    ${id}
    ${list}    Module Exec    ThreatIoc    get_alerttype_by_id    id=${id}
    [Return]    ${list}

Get IntranetIP with Ioc
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    get_related_intranrtip    ioc=${ioc}
    [Return]    ${list}

Get Ice list with Ioc
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    get_ice_related_to_ioc    ioc=${ioc}
    [Return]    ${list}

Get Portinfo with Ioc
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    get_portinfo_details    ioc=${ioc}
    [Return]    ${list}

Get RelatedInfo with ioc
    [Arguments]    ${ioc}
    ${list}    Module Exec    ThreatIoc    get_relatedinfo_details    ioc=${ioc}
    [Return]    ${list}
