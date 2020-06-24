*** Settings ***
Resource           ./kw_utils.robot


*** Keywords ***
### 资产操作 ###
Search Asset By Type
    [Documentation]    根据ip/负责人/资产名称搜索资产
    [Arguments]    ${type}    ${value}    ${tags}=${EMPTY}
    ${data}=    Module Exec    Asset    search_asset_avdr    search_type=${type}    search_value=${value}    tags=${tags}
    [Return]    ${data}

Search Assets By Tags
    [Documentation]    根据资产标签搜索资产
    [Arguments]  ${tags}=${EMPTY}}
    ${data}=    MODULE EXEC    Asset    search_asset_tag_avdr    tags=${tags}
    [Return]    ${data}

Clear Assets
    [Documentation]    清空所有资产
    ${data}=    MODULE EXEC    Asset    clear_asset

Import Assets
    [Documentation]    通过excel导入资产
    [Arguments]    ${local_file}
    ${data}=    MODULE EXEC    Asset    import_asset    local_file=${local_file}
    [Return]    ${data}

Export Assets
    [Documentation]    导出资产.xlsx文件
    [Arguments]    ${file_path}
    ${data}    MODULE EXEC    Asset    export_assets    file_path=${file_path}
    [Return]    ${data}


#### 标签操作 ####
Add tag for Asset
    ####先获取对应资产，将资产相关信息传给添加标签的请求体
    [Documentation]    为资产添加标签
    [Arguments]    ${asset_ip}    ${tags}
    log    ${asset_ip}
    ${data_asset}=    Search Asset By Type    type=general_ip    value=${asset_ip}
    &{dic}    create dictionary    tags=${tags}    asset_ip=${data_asset[0]['ip_address']}    asset_name=${data_asset[0]['asset_name']}    asset_id=${data_asset[0]['asset_id']}    id1=${data_asset[0]['_id']}
    ${data}    MODULE EXEC      Asset    add_tag   &{dic}
    #${data}    MODULE EXEC      Asset    add_tag   tags=${tags}    asset_ip=${data_asset[0]['ip_address']}    asset_name=${data_asset[0]['asset_name']}    asset_id=${data_asset[0]['asset_id']}    id1=${data_asset[0]['_id']}
    [Return]    ${data}


Get All Tags
    [Documentation]    查询所有标签
    ${data}=    MODULE EXEC  Asset    get_tags
    [Return]    ${data}