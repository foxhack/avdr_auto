*** Settings ***
Resource          kw_utils.robot

*** Keywords ***
####### 资产操作相关 #######
Add Asset
    [Arguments]    ${asset_name}=${EMPTY}    ${ip_address}=${EMPTY}    ${asset_type}=${EMPTY}    ${asset_owner}=${EMPTY}    ${business_name}=${EMPTY}
    ${random_name}    Generate Random Name    asset_
    ${asset_name}    Set Variable If    '${asset_name}'=='${EMPTY}'    ${random_name}    ${asset_name}
    ${random_ip}    Generate Random IP
    ${ip_address}    Set Variable If    '${ip_address}'=='${EMPTY}'    ${random_ip}    ${ip_address}
    ${asset_type}    Set Variable If    '${asset_type}'=='${EMPTY}'    Windows    ${asset_type}
    ${asset_owner}    Set Variable If    '${asset_type}'=='${EMPTY}'    new    ${asset_owner}
    ${id}    Module Exec    Asset    create    asset_name=${asset_name}    ip_address=${ip_address}    asset_type_name=${asset_type}    asset_owner=${asset_owner}    business_name=${business_name}
    [Return]    ${id}    ${asset_name}    ${random_ip}

Get Asset by ID
    [Arguments]    ${asset_id}
    ${asset_info}    Module Exec    Asset    get    id=${asset_id}
    [Return]    ${asset_info}

Delete All Asset
    Module Exec    Asset    delete_all

Delete Asset by ID
    [Arguments]    ${asset_id}
    Module Exec    Asset    delete    id=${asset_id}

Import Asset
    [Arguments]    ${local_file}
    Module Exec    Asset    import_asset    local_file=${local_file}

Import Asset Vulnerability
    [Arguments]    ${local_file}
    Module Exec    Vulnerability    import_vul    local_file=${local_file}

Generate Score
    Module Exec    Vulnerability    run_score

Get Asset Score
    [Arguments]    ${ip}
    ${data}    Module Exec    Asset    get_score    ip=${ip}
    [Return]    ${data}

Get Asset View Score
    [Arguments]    ${scope}=3    ${keyword}=3
    ${data}    Module Exec    Asset    get_score_by_dimension_scope    dim_scope=${scope}    keyword=${keyword}
    [Return]    ${data}

Asset Score is Not Empty
    [Arguments]    ${condition}=${EMPTY}
    ${data}=    Module Exec    Asset    query_risk_score_info    condition=${condition}
    Should Not Be Equal As Integers    ${data['total']}    0 

Search asset by filter
    [Arguments]    ${type}    ${filter}
    ${data}    Module Exec    Asset    search_asset    search_type=${type}    search_keyword=${filter}
    [Return]    ${data}

Add custom tags
    [Arguments]    ${tags}
    Module Exec    Asset    add_custom_tag    tag=${tags}

Search asset by tags
    [Arguments]    ${tags}
    ${data}    Module Exec    Asset    search_asset_by_tag    tags=${tags}
    [Return]    ${data}

Get Risk Asset By Business
    [Arguments]    ${business_id}=${EMPTY}
    ${data}    Module Exec    Asset    get_risk_asset_by_business    business_id=${business_id}
    [Return]    ${data}

####### 资产类型 #######

Add asset type
    [Arguments]    ${name}=${EMPTY}    ${parent_type_name}=${EMPTY}
    ${random_name}    Generate Random Name    type_
    ${type_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${id}    Module Exec    AssetType    create    name=${type_name}    parent_name=${parent_type_name}
    [Return]    ${id}    ${type_name}

Get asset type by ID
    [Arguments]    ${id}
    ${type}    Module Exec    AssetType    get    id=${id}
    [Return]    ${type}

Delete asset type
    [Arguments]    ${id}
    Module Exec    AssetType    delete    id=${id}

####### 资产安全域 #######

Add security domain
    [Arguments]    ${name}=${EMPTY}    ${parent_domain_name}=${EMPTY}
    ${random_name}    Generate Random Name    domain_
    ${domain_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${id}    Module Exec    AssetDomain    create    name=${domain_name}    parent_name=${parent_domain_name}
    [Return]    ${id}    ${domain_name}

Get security domain by ID
    [Arguments]    ${id}
    ${domain}    Module Exec    AssetDomain    get    id=${id}
    [Return]    ${domain}

Delete security domain
    [Arguments]    ${id}
    Module Exec    AssetDomain    delete    id=${id}

####### 资产业务系统 #######

Add business
    [Arguments]    ${name}=${EMPTY}    ${parent_business_name}=${EMPTY}
    ${random_name}    Generate Random Name    business_
    ${business_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${id}    Module Exec    AssetBusiness    create    name=${business_name}    parent_name=${parent_business_name}
    [Return]    ${id}    ${business_name}

Get business by ID
    [Arguments]    ${id}
    ${business}    Module Exec    AssetBusiness    get    id=${id}
    [Return]    ${business}

Delete business
    [Arguments]    ${id}
    Module Exec    AssetBusiness    delete    id=${id}

####### 资产物理位置 #######

Add location
    [Arguments]    ${name}=${EMPTY}    ${parent_location_name}=${EMPTY}
    ${random_name}    Generate Random Name    location_
    ${location_name}    Set Variable If    '${name}'=='${EMPTY}'    ${random_name}    ${name}
    ${id}    Module Exec    AssetLocation    create    name=${location_name}    parent_name=${parent_location_name}
    [Return]    ${id}    ${location_name}

Get location by ID
    [Arguments]    ${id}
    ${location}    Module Exec    AssetLocation    get    id=${id}
    [Return]    ${location}

Delete location
    [Arguments]    ${id}
    Module Exec    AssetLocation    delete    id=${id}