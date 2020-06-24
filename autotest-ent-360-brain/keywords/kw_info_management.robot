*** Settings ***
Variables         ../config/config.py
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           String

*** Keywords ***
Get InformationGroup By Name
    [Arguments]    ${name}
    ${list}    Module Exec    InformationGroup    get_by_name    name=${name}
    [Return]    ${list}

Get parentId By groupType
    [Arguments]    ${group_name}
    ${sql}    set variable    SELECT id_path FROM `security_intelligence_group` WHERE name_path=${group_name}
    ${id_path}=    Execute Mysql Cmd    ${sql}    #get parent_id by information type
    ${parentId}=    set variable    ${id_path[-12:]}
    [Return]    ${parentId}

Create Information Group
    [Arguments]    ${name}    ${type}    ${parentid}    ${inType}
    ${list}    Module Exec    InformationGroup    create_informationGroup    name=${name}    type=${type}    parentid=${parentid}
    ...    inType=${inType}
    [Return]    ${list}

Delete Information Group
    [Arguments]    ${name}
    Module Exec    InformationGroup    delete_informationGroup_by_name    name=${name}

Update Information Group
    [Arguments]    ${name1}    ${name2}
    ${list}    Module Exec    InformationGroup    update    name1=${name1}    name2=${name2}
    [Return]    ${list}

List Information
    ${list}    Module Exec    Information    list
    [Return]    ${list}

Create Information By Data
    [Arguments]    &{data}
    Module Exec    Information    create_by_data    data=&{data}

Create Information By FileContent
    [Arguments]    ${data}
    Module Exec    Information    create_by_filecontent    data=${data}

Update Information
    [Arguments]    ${id}    &{data}
    Module Exec    Information    update    id=${id}    data=&{data}

Query By Content
    [Arguments]    ${content}
    ${list}    Module Exec    Information    query_by_content    content=${content}
    [Return]    ${list}

Query By Idpath
    [Arguments]    ${idpath}
    ${list}    Module Exec    Information    query_by_idpath    idpath=${idpath}
    [Return]    ${list}

Delete Information
    [Arguments]    ${id}
    Module Exec    Information    delete    id=${id}

Export All Information
    [Arguments]    ${local_file}
    Module Exec    Information    export_all    local_file=${local_file}
