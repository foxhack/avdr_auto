*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
Clear ICE Data
    Execute SSH Cmd    /opt/hansight/enterprise/hanctl stop incident
    Sleep  20
    Execute SSH Cmd    sed -i "s/cache_clear: false/cache_clear: true/g" /opt/hansight/enterprise/incident/application.yml
    Module Exec    Elasticsearch    delete_index
    Execute SSH Cmd    rm -rf /opt/hansight/enterprise/incident/logs/incident.log
    Execute SSH Cmd    /opt/hansight/enterprise/hanctl start incident
    Execute SSH Cmd    rm -rf /opt/hansight/enterprise/incident/.sequence

Search Incident List
    [Arguments]    ${condition}=${EMPTY}
    ${data}=    Module Exec    Incident    get_incident_list    condition=${condition}
    [Return]    ${data}

Delete Incident
    [Arguments]    ${id}
    Module Exec    Incident    delete_incident    id=${id}

Add Incident To Case
    [Arguments]    ${name}
    Module Exec    Incident    add_incident_to_case    name=${name}

Change Incident To Owner
    [Arguments]    ${id}    ${user_id}
    Module Exec    Incident    change_incident_owner    id=${id}    user_id=${user_id}

Handle Incident To Status
    [Arguments]    ${id}    ${handle_status}
    Module Exec    Incident    change_incident_handle_status    id=${id}    status=${handle_status}

Confirm Incident To Status
    [Arguments]    ${id}    ${confirm_status}
    Module Exec    Incident    change_incident_ack_status    id=${id}    status=${confirm_status}

Get Incident Status Change History
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_audit_history    id=${id}
    [Return]    ${data}

Get Incident Handle Advice
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_advice    id=${id}
    [Return]    ${data}

Get Incident Latest Events and Alerts Statistics
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_latest_event_alert    id=${id}
    [Return]    ${data}

Get Incident IP Relation Data
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_ip_relation_info    id=${id}
    [Return]    ${data}

Get Incident Details
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_detail_timeline    id=${id}
    [Return]    ${data}

Get Incident Detail Tendency Count
    [Arguments]    ${id}    ${type}
    ${count}=    Module Exec    Incident    get_incident_merge_tendency    id=${id}    dtype=${type}
    [Return]    ${count}

Get Incident Graph Data
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_graph    id=${id}
    [Return]    ${data}

Get Incident Sankey Diagram Data
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_sankey_diagram    id=${id}
    [Return]    ${data}

Delete Merged Alert From Incident
    [Arguments]    ${id}
    Module Exec    Incident    delete_merge_alert    id=${id}

Get Incident Basic Info
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_incident_info    id=${id}
    [Return]    ${data}

Update Incident With Fileds
    [Arguments]    ${id}    &{args}
    Module Exec    Incident    update_incident    id=${id}    &{args}

Get All Incident Rules
    ${data}=    Module Exec    Incident    list_incident_rules
    [Return]    ${data}

Get All Incident Rule Types
    ${data}=    Module Exec    Incident    list_incident_rule_types
    [Return]    ${data}

Get Attck List
    ${data}=    Module Exec    Incident    get_all_attcks
    [Return]    ${data}

Get Mapping Attack List
    ${data}=    Module Exec    Incident    get_mapping_attcks
    [Return]    ${data}

Get Attck Tech Info
   [Arguments]    ${id}
   ${data}=    Module Exec    Incident    get_technique_info    tech_id=${id}
   [Return]    ${data}

Get Incident Rule
    [Arguments]    ${id}
    ${data}=    Module Exec    Incident    get_icerule    id=${id}
    [Return]    ${data}

Get Incident Rule By Name
    [Arguments]    ${name}
    ${data}=    Module Exec    Incident    get_icerule_by_name    name=${name}
    [Return]    ${data}

Update Incident Rule Notification
    [Arguments]    ${id}    ${notifier}    ${notification}
    Module Exec    Incident    update_incident_rule_notification    id=${id}    notifier=${notifier}    notification=${notification}