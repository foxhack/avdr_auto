*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List CEP Rule
    [Documentation]    list current cep rules
    ${list_cep_rules}    Module Exec    CepRule    list
    [Return]    ${list_cep_rules}

Get CEP Rule
    [Arguments]    ${name}
    [Documentation]    get cep rule info by cep rule name
    ${rule_info}    Module Exec    CepRule    get_by_name    name=${name}
    [Return]    ${rule_info}

List CEP Rule Type
    [Documentation]    list current cep rule types
    ${list_cep_types}    Module Exec    CEPRuleType    list
    [Return]    ${list_cep_types}

Get CEP Rule By ID
    [Arguments]    ${id}
    [Documentation]    get cep rule info by cep rule id
    ${rule_info}    Module Exec    CepRule    get    id=${id}
    [Return]    ${rule_info}

Start CEP
    [Arguments]    ${id}=${EMPTY}
    [Documentation]    start cep rules, if id not given, then start all cep rules
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    CepRule    start    id=${id}
    ...    ELSE    Module Exec    CepRule    start_all

Stop CEP
    [Arguments]    ${id}=${EMPTY}
    [Documentation]    stop cep rules, if id not given, then stop all cep rules
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    CepRule    stop    id=${id}
    ...    ELSE    Module Exec    CepRule    stop_all

Delete CEP
    [Arguments]    ${id}
    [Documentation]    delete cep rule
    Module Exec    CepRule    delete    id=${id}

Update CEP Rule
    [Arguments]    ${id}    &{kwargs}
    [Documentation]    update cep rule
    Module Exec    CepRule    update    id=${id}    &{kwargs}

Import CEP Rule
    [Arguments]    ${localfile}    ${strategy}=${EMPTY}
    [Documentation]    import cep rule from local file
    ${uri}    Module Exec    CepRule    import_rule    localfile=${localfile}    strategy=${strategy}
    [Return]    ${uri}

Export CEP Rule
    [Arguments]    ${localfile}    ${id_list}=${EMPTY}
    [Documentation]    export cep rule to local file
    Module Exec    CepRule    export_rule    localfile=${localfile}    id_list=${id_list}

Check CEP Rule
    [Documentation]    check if output attrs and alarm content match for cep rules
    ${issue_rules}    Module Exec    CepRule    check_alarm_content_output
    [Return]    ${issue_rules}

Check CEP Rule Output
    [Documentation]    check if output attrs are correct for cep rules
    ${issue_rules}    Module Exec    CepRule    cep_rule_output_check
    [Return]    ${issue_rules}

Check CEP Rule Alert Config Setting
    [Documentation]    check if alert notification is set in cep rules
    ${issue_rules}    Module Exec    CepRule    cep_rule_alarm_notification_check
    [Return]    ${issue_rules}

Get Buildin CEP Rule List
    [Documentation]    get build in cep rule name list
    ${issue_rules}    Module Exec    CepRule    get_buildin_cep_rule_list
    [Return]    ${issue_rules}

Create CEP Rule
    [Arguments]    ${type_name}    ${template_name}    ${alert}=${EMPTY}    ${name}=${EMPTY}    ${desc}=${EMPTY}    ${status}=${1}
    ...    ${events}=${EMPTY}    ${selects}=${EMPTY}    ${inner_event}=${EMPTY}    ${window}=${EMPTY}    ${groupby}=${EMPTY}    ${having}=${EMPTY}
    ...    ${has_context}=${False}    ${context_name}=${EMPTY}    ${where}=${EMPTY}    ${editable}=${1}
    [Documentation]    create cep rule, type name and template name is required
    ${random_name}    Generate Random Name    ceprule_
    ${name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    Module Exec    CepRule    create    name=${name}    desc=${desc}    status=${status}    type_name=${type_name}
    ...    template_name=${template_name}    events=${events}    selects=${selects}    alert=${alert}    inner_event=${inner_event}    window=${window}
    ...    groupby=${groupby}    having=${having}    has_context=${has_context}    context_name=${context_name}    where=${where}    editable=${editable}
    [Return]    ${name}

Create CEP Rule By File
    [Arguments]    ${file_path}    ${name}=${EMPTY}
    [Documentation]    create cep rule by file
    ${random_name}    Generate Random Name    ceprule_file_
    ${name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    Module Exec    CepRule    create_by_file    rule_file=${file_path}    name=${name}
    [Return]    ${name}

Get CEP Event By Name
    [Arguments]    ${event_name}
    [Documentation]    get cep source event info
    ${event_info}    Module Exec    CepRule    get_event_by_name    name=${event_name}
    [Return]    ${event_info}

Get CEP Event Attr By Name
    [Arguments]    ${event}    ${attr_name}
    [Documentation]    get cep source event attribute by attr name
    ${attr_info}    Module Exec    CepRule    get_eventattr_by_name    event=${event}    attr_name=${attr_name}
    [Return]    ${attr_info}

Generate Alert Dict
    [Arguments]    ${b_enabled}=${TRUE}    ${alarm_type}=${EMPTY}    ${alarm_stage}=${EMPTY}    ${alarm_level}=${EMPTY}    ${alarm_content}=${EMPTY}    ${notification_enabled}=${EMPTY}
    ...    ${notification_config}=${EMPTY}
    [Documentation]    generate alarm alert dict ,for Create cep rule use purpose
    ${alert}    Module Exec    CepRule    generate_alert    b_enabled=${b_enabled}    alarm_type=${alarm_type}    alarm_stage=${alarm_stage}
    ...    alarm_level=${alarm_level}    alarm_content=${alarm_content}    notification_enabled=${notification_enabled}    notification_config=${notification_config}
    [Return]    ${alert}

Create Event Dict
    [Arguments]    ${event_id}    ${event_name}    ${event_type}    ${event_alias}    ${event_filter}=${EMPTY}
    [Documentation]    generate event dict ,for Create cep rule use purpose
    ${event_dict}    Module Exec    CepRule    generate_event_dict    event_id=${event_id}    event_name=${event_name}    event_type=${event_type}
    ...    event_alias=${event_alias}    event_filter=${event_filter}
    [Return]    ${event_dict}

Create Select Item
    [Arguments]    ${event_attr}    ${event}    ${has_alias}=${False}    ${alias}=${EMPTY}    ${has_func}=${False}    ${func}=${EMPTY}
    [Documentation]    generate select item dict ,for Create cep rule use purpose
    ${select_item_dict}    Module Exec    CepRule    generate_select_item    attr=${event_attr}    event=${event}    has_alias=${has_alias}
    ...    alias=${alias}    has_fn=${has_func}    fn=${func}
    [Return]    ${select_item_dict}

Get Event Attrs For CEP
    [Arguments]    ${event_name}
    [Documentation]    get event attr list of specific event for cep init
    ${attr_list}    Module Exec    CepRule    get_event_attr_list    event_name=${event_name}
    [Return]    ${attr_list}

Create SAE Task
    [Arguments]    @{rules}
    ${name}    Generate Random Name    test_sae_task_
    Module Exec    CepTask    create    name=${name}    rule_list=@{rules}
    [Return]    ${name}

Get SAE Task
    [Arguments]    ${name}
    ${task}    Module Exec    CepTask    get_by_name    name=${name}
    [Return]    ${task}

Delete SAE Task
    [Arguments]    ${id}
    Module Exec    CepTask    delete    id=${id}