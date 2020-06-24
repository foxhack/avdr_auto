*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
List DV Collector
    ${list_collectors}    Module Exec    DVCollector    list
    [Return]    ${list_collectors}

Get DV Collector Status
    [Arguments]    ${id}
    ${list_collectors}    Module Exec    DVCollector    get_worker_status    id=${id}
    [Return]    ${list_collectors}

List DV Parser
    ${list_parsers}    Module Exec    DVParser    list
    [Return]    ${list_parsers}

Get DV Parser
    [Arguments]    ${name}
    ${parser_info}    Module Exec    DVParser    get_by_name    name=${name}
    [Return]    ${parser_info}

Get DV Parser By ID
    [Arguments]    ${id}
    ${parser_info}    Module Exec    DVParser    get    id=${id}
    [Return]    ${parser_info}

Delete DV Parser
    [Arguments]    ${id}=${EMPTY}    ${name}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    DVParser    delete    id=${id}
    ...    ELSE IF    '${name}'!='${EMPTY}'    Module Exec    DVParser    delete_by_name    name=${name}
    ...    ELSE    Module Exec    DVParser    delete_all

Create DV Parser With File
    [Arguments]    ${local_file}    ${name}=${EMPTY}
    ${parser_id}    ${parser_name}    Module Exec    DVParser    create_by_file    local_file=${local_file}    name=${name}
    [Return]    ${parser_id}    ${parser_name}

Create DV Parser With Post Data File
    [Arguments]    ${post_json_file}
    ${content}    Get File    ${post_json_file}
    ${data}    evaluate     ${content}
    Module Exec    DVParser    create_by_data    data=${data}

Import DV Parse Rule File
    [Arguments]    ${local_file}
    Module Exec    DVParser    import_parser_rule_file    local_file=${local_file}

Export DV Parse Rule File
    [Arguments]    ${local_file}    ${rule_name}=${EMPTY}
    Module Exec    DVParser    export_parser_rule_file    local_file=${local_file}    rule_name=${rule_name}

List DV Source
    ${list_sources}    Module Exec    DVSource    list
    [Return]    ${list_sources}

Get DV Source
    [Arguments]    ${name}
    ${source_info}    Module Exec    DVSource    get_by_name    name=${name}
    [Return]    ${source_info}

Get DV Source By ID
    [Arguments]    ${id}
    ${source_info}    Module Exec    DVSource    get    id=${id}
    [Return]    ${source_info}

Delete DV Source
    [Arguments]    ${id}=${EMPTY}    ${name}=${EMPTY}
    Run Keyword If    '${id}'!='${EMPTY}'    Module Exec    DVSource    delete    id=${id}
    ...    ELSE IF    '${name}'!='${EMPTY}'    Module Exec    DVSource    delete_by_name    name=${name}
    ...    ELSE    Module Exec    DVSource    delete_all

Stop and Delete All DV Source
    Module Exec    DVSource    stop_delete_all

Start DV Source
    [Arguments]    ${name}=${EMPTY}
    Module Exec    DVSource    start_by_name    name=${name}

Stop DV Source
    [Arguments]    ${name}=${EMPTY}
    Module Exec    DVSource    stop_by_name    name=${name}

Create DV Source
    [Arguments]    ${name}=${EMPTY}    ${collector}=${EMPTY}    ${resolver}=${EMPTY}    ${source_ip}=${EMPTY}    ${source_data}=${EMPTY}
    Module Exec    DVSource    create    name=${name}    collector=${collector}    resolver=${resolver}    source_ip=${source_ip}
    [Return]    ${name}

Create DV Syslog Source
    [Arguments]    ${resolver}
    ${name}    Generate Random Name    dv_syslog_source_
    ${content}    Get File    testdata/dv/syslog_source.json
    ${local_ip}    Get Local IP
    ${source_data}    evaluate    ${content}
    Set To Dictionary    ${source_data}    deviceIp=${local_ip}
    Log    ${source_data}
    ${source_name}    Create DV Source    name=${name}    collector=worker-001    resolver=${resolver}    source_ip=${local_ip}
    [Return]    ${name}

Create DV Kafka Source
    [Arguments]    ${resolver}    ${topic}=test    ${kafka_ip_port}=127.0.0.1:9092
    ${name}    Generate Random Name    dv_kafka_
    Module Exec    DVSource    create_kafka_type    name=${name}    resolver=${resolver}    topic=${topic}    source_ip=${kafka_ip_port}
    [Return]    ${name}

Create DV File Source
    [Arguments]    ${resolver}    ${file}
    ${name}    Generate Random Name    dv_file_
    Module Exec    DVSource    create_file_type    name=${name}    resolver=${resolver}    file_path=${file}
    [Return]    ${name}

Create DV Self DB Source
    [Arguments]    ${resolver}
    ${name}    Generate Random Name    dv_db_
    Module Exec    DVSource    create_db_type    name=${name}    resolver=${resolver}
    [Return]    ${name}

Create DV Self SFTP Source
    [Arguments]    ${resolver}    ${file}
    ${name}    Generate Random Name    dv_sftp_
    Module Exec    DVSource    create_sftp_type    name=${name}    resolver=${resolver}    filepath=${file}
    [Return]    ${name}

Create DV Collector with Parser Rules
    [Arguments]    @{rules}
    Stop and Delete All DV Source
    ${source_name}    Create DV Syslog Source    resolver=@{rules}
    Start DV Source    ${source_name}

Search DV Source By Name
    [Arguments]    ${name}
    ${info}    Module Exec    DVSource    get_by_name    name=${name}
    [Return]    ${info}

Search DV Store By Name
    [Arguments]    ${name}
    ${info}    Module Exec    DVStore    get_by_name    name=${name}
    [Return]    ${info}

Create Kafka DV Store
    [Arguments]    ${name}    ${address}
    Module Exec    DVStore    create    store_type=kafka    name=${name}    address=${address}

Create ES DV Store
    [Arguments]    ${name}    ${address}
    Module Exec    DVStore    create    store_type=es    name=${name}    address=${address}

Create Net DV Store
    [Arguments]    ${name}    ${address}
    Module Exec    DVStore    create    store_type=net    name=${name}    address=${address}

Delete DV Store
    [Arguments]    ${name}
    ${store_info}    Search DV Store By Name    name=${name}
    Module Exec    DVStore    delete    id=${store_info["id"]}