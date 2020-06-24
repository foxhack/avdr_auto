*** Settings ***
Documentation     Test for Hansight Enterprise
Test Setup        Test Setup
Test Teardown     Test Teardown
Library           OperatingSystem
Resource          kw_ent.robot
Resource          kw_alarm.robot
Resource          kw_whitelist.robot
Resource          kw_threat.robot
Resource          kw_utils.robot
Resource          kw_dataviewer.robot
Resource          kw_sys_cfg.robot
Resource          kw_info_management.robot

*** Variables ***
${export_global_whitelist_file}    export_global_whitelist.xlsx
${export_intelligence_whitelist_file}    export_local_intelligence_whitelist.xlsx
${file_path}      testdata/whitelist/intelligence_whitelist_cn.xlsx
${global_file}    testdata/whitelist/global_whitelist_cn.xlsx

*** Test Cases ***
Add Global Whitelist --IP Vaule Type
    Delete All Global-whitelist
    ${ip1}    set variable    5.6.5.4
    &{data}    Create Dictionary    content    ${ip1}    contentType    SINGLE    type
    ...    IP
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Global-whitelist

Add Global Whitelist-- IP COUPLE Type
    Delete all Global-whitelist
    ${ip_couple}    set variable    1.12.1.1-1.12.1.2
    &{data}    Create Dictionary    content    ${ip_couple}    contentType    COUPLE    type
    ...    IP
    Add Global Whitelist Value    data=&{data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Global-whitelist

Add Global Whitelist-- IP SUBNETMASK Type
    Delete all Global-whitelist
    ${ip_netmask}    set variable    3.3.3.1/31
    &{data}    Create Dictionary    content    ${ip_netmask}    contentType    SUBNETMASK    type
    ...    IP
    Add Global Whitelist Value    data=&{data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Global-whitelist

Add Global Whitelist --Domain Type
    Delete All Global-whitelist
    ${domain}    set variable    www.baidu.com
    &{data}    Create Dictionary    content    ${domain}    contentType    SINGLE    type
    ...    DOMAIN
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Global-whitelist

Add Global Whitelist --URL Type
    Delete All Global-whitelist
    ${url}    set variable    http://www.baidu.com
    &{data}    Create Dictionary    content    ${url}    contentType    SINGLE    type
    ...    URL
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Global-whitelist

Add Global Whitelist --ACCOUNT Type
    Delete All Global-whitelist
    ${account}    set variable    test account
    &{data}    Create Dictionary    content    ${account}    contentType    SINGLE    type
    ...    ACCOUNT
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete All Global-whitelist

Modify Global Whitelist
    Delete All Global-whitelist
    ${ip1}    set variable    5.6.5.4
    &{data}    Create Dictionary    content    ${ip1}    contentType    SINGLE    type
    ...    IP
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    ${ip2}    set variable    6.7.8.3
    log    ${list[0]['id']}
    Modify Global Whitelist    ${list[0]['id']}    ${ip2}
    ${list}    Get global-whitelist
    should be equal    ${list[0]['content']}    ${ip2}
    Delete All Global-whitelist

Query Globalwhitelist
    Delete All Global-whitelist
    ${ip1}    set variable    5.6.5.4
    &{data}    Create Dictionary    content    ${ip1}    contentType    SINGLE    type
    ...    IP
    Add Global Whitelist Value    data=${data}
    ${list}    Get global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    ${list}    Query Global Whitelist    ${ip1}
    log    ${list[0]['content']}
    ${len}    get length    ${list}
    should not be equal as integers    ${len}    ${0}
    Delete All Global-whitelist

Import Global Whitelist
    Delete all Global-whitelist
    Import Global Whitelist    ${global_file}
    ${list}    Get Global-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${24}
    Delete all Global-whitelist

Export All Global Whitelist
    Delete all Global-whitelist
    Import Global Whitelist    ${file_path}
    Export All Global Whitelist    ${export_global_whitelist_file}

Add Intelligence Whitelist-- IP Value Type
    Delete all Ioc-whitelist
    ${ioc_ip}    set variable    5.6.7.8
    &{data}    Create Dictionary    content    ${ioc_ip}    contentType    SINGLE    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Ioc-whitelist

Add Intelligence Whitelist-- IP COUPLE Type
    Delete all Ioc-whitelist
    ${ip_couple}    set variable    1.12.1.1-1.12.1.2
    &{data}    Create Dictionary    content    ${ip_couple}    contentType    COUPLE    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Ioc-whitelist

Add Intelligence Whitelist-- IP SUBNETMASK Type
    Delete all Ioc-whitelist
    ${ip_netmask}    set variable    3.3.3.1/31
    &{data}    Create Dictionary    content    ${ip_netmask}    contentType    SUBNETMASK    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Ioc-whitelist

Add Intelligence Whitelist-- DOMAIN Type
    Delete all Ioc-whitelist
    ${domain}    set variable    www.bing.com
    &{data}    Create Dictionary    content    ${domain}    contentType    SINGLE    type
    ...    Domain
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Ioc-whitelist

Delete Intelligence whitelist
    Delete all Ioc-whitelist
    ${ioc_ip}    set variable    5.6.7.8
    &{data}    Create Dictionary    content    ${ioc_ip}    contentType    SINGLE    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    Delete all Ioc-whitelist
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${0}

Query Intelligence Whitelist
    Delete all Ioc-whitelist
    ${ioc_ip}    set variable    6.7.8.9
    &{data}    Create Dictionary    content    ${ioc_ip}    contentType    SINGLE    type
    ...    IP
    Add Ioc Whitelist Value    data=&{data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${1}
    ${query_list}    Query Ioc Whitelist    ${ioc_ip}
    should not be empty    ${query_list}
    Delete all Ioc-whitelist

Modify Intelligence Whitelist
    Delete all Ioc-whitelist
    ${ip1}    set variable    5.6.7.8
    &{data}    Create Dictionary    content    ${ip1}    contentType    SINGLE    type
    ...    IP
    Add Ioc Whitelist Value    data=${data}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal    ${list[0]['content']}    ${ip1}
    ${ip1_mod}    set variable    6.5.4.3
    Modify Ioc Whitelist    ${list[0]['id']}    ${ip1_mod}
    ${list}    Get Ioc-whitelist
    should be equal    ${list[0]['content']}    ${ip1_mod}
    Delete all Ioc-whitelist

Import Intelligence Whitelist
    Delete all Ioc-whitelist
    Import Intelligence Whitelist    ${file_path}
    ${list}    Get Ioc-whitelist
    ${len}    get length    ${list}
    should be equal as integers    ${len}    ${24}
    Delete all Ioc-whitelist

Export All Intelligence Whitelist
    Delete all Ioc-whitelist
    Import Intelligence Whitelist    ${file_path}
    Export All Intelligence Whitelist    ${export_intelligence_whitelist_file}

Create InformationGroup--IP Type
    ${name}    set variable    test_ip_type
    Delete Information Group    ${name}
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--Digit Type
    ${name}    set variable    test_digit_type
    ${type}    set variable    num
    ${informationType}    set variable    端口
    log    ${informationType}
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/数字类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--String 字符串比较
    ${name}    set variable    test_string_compare
    ${type}    set variable    string
    ${informationType}    set variable    字符串比较
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--String 正则部分匹配
    ${name}    set variable    test_partRegx
    ${type}    set variable    string
    ${informationType}    set variable    正则部分匹配
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--String 正则全匹配
    ${name}    set variable    test_AllRegx
    ${type}    set variable    string
    ${informationType}    set variable    正则全匹配
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--Time 相对时间
    ${name}    set variable    test_relative_time
    ${type}    set variable    time
    ${informationType}    set variable    相对时间
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Create InformationGroup--Time 绝对时间
    ${name}    set variable    test_absolute_time
    ${type}    set variable    time
    ${informationType}    set variable    绝对时间
    Delete Information Group    ${name}
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    Delete Information Group    ${name}

Modify Information Group--IP Type
    ${name1}    set variable    testZHOU1
    ${name2}    set variable    testZHOU2
    Delete Information Group    ${name1}
    Delete Information Group    ${name2}
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name1}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_mod}    Update Information Group    ${name1}    ${name2}
    log    ${list_mod['name']}
    should be equal    ${list_mod['name']}    ${name2}
    Delete Information Group    ${name2}

Modify Information Group--Digit Type
    ${name1}    set variable    test_digit1
    ${name2}    set variable    test_digit2
    Delete Information Group    ${name1}
    Delete Information Group    ${name2}
    ${type}    set variable    num
    ${informationType}    set variable    端口
    ${group_name}    set variable    "/信息管理/数字类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name1}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_mod}    Update Information Group    ${name1}    ${name2}
    should be equal    ${list_mod['name']}    ${name2}
    Delete Information Group    ${name2}

Modify Information Group--String Type
    ${name1}    set variable    test_string1
    ${name2}    set variable    test_string2
    Delete Information Group    ${name1}
    Delete Information Group    ${name2}
    ${type}    set variable    string
    ${informationType}    set variable    字符串比较
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name1}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_mod}    Update Information Group    ${name1}    ${name2}
    should be equal    ${list_mod['name']}    ${name2}
    Delete Information Group    ${name2}

Modify Information Group--Time Type
    ${name1}    set variable    test_time1
    ${name2}    set variable    test_time2
    Delete Information Group    ${name1}
    Delete Information Group    ${name2}
    ${type}    set variable    time
    ${informationType}    set variable    相对时间
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name1}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_mod}    Update Information Group    ${name1}    ${name2}
    should be equal    ${list_mod['name']}    ${name2}
    Delete Information Group    ${name2}

Create Information--IP Value Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    5.5.5.10
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--IP Couple Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    3.3.3.3-3.3.3.4
    ${contentType}    set variable    couple
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_group}    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--IP SubNetMask Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    3.3.3.3/16
    ${contentType}    set variable    subnetmask
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_group}
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--Digit Value Type
    ${name}    set variable    test_digit_type
    ${type}    set variable    num
    ${informationType}    set variable    端口
    ${group_name}    set variable    "/信息管理/数字类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    10811
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_group}
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--String Value Type
    ${name}    set variable    test_string_compare
    ${type}    set variable    string
    ${informationType}    set variable    字符串比较
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_string.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--String Value Type -- 正则部分匹配
    ${name}    set variable    test_partRegx
    ${type}    set variable    string
    ${informationType}    set variable    正则部分匹配
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_part_regex.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--String Value Type -- 正则全匹配
    ${name}    set variable    test_Allregex
    ${type}    set variable    string
    ${informationType}    set variable    正则全匹配
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_allregx.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--Time 相对时间
    ${name}    set variable    test_relative_time
    ${type}    set variable    time
    ${informationType}    set variable    相对时间
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    ${groupId}    set variable    ${list['id']}
    ${content}    OperatingSystem.get file    ./testdata/information/relative_time_info
    ${content_reg1}=    replace string using regexp    ${content}    "groupId":.*?,    "groupId":"${groupId}",
    ${content_reg2}=    replace string using regexp    ${content_reg1}    "typeId":.*?,    "typeId":"${groupId}",
    ${data}=    replace string using regexp    ${content_reg2}    "name":.*?,    "name":"${name}",
    Create Information By FileContent    ${data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Create Information--Time 绝对时间
    ${name}    set variable    test_absolute_time
    ${type}    set variable    time
    ${informationType}    set variable    绝对时间
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}
    should not be empty    ${list_name[u'intelligenceType']}
    ${groupId}    set variable    ${list['id']}
    ${content}    OperatingSystem.get file    ./testdata/information/absolute_time_info
    ${content_reg1}=    replace string using regexp    ${content}    "groupId":.*?,    "groupId":"${groupId}",
    ${content_reg2}=    replace string using regexp    ${content_reg1}    "typeId":.*?,    "typeId":"${groupId}",
    ${data}=    replace string using regexp    ${content_reg2}    "name":.*?,    "name":"${name}",
    Create Information By FileContent    ${data}
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--IP Value Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    5.5.5.10
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    7.7.7.7
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--IP Couple Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    3.3.3.3-3.3.3.4
    ${contentType}    set variable    couple
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    7.7.7.7-7.7.7.8
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--IP SubNetMask Type
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    3.3.3.3/16
    ${contentType}    set variable    subnetmask
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    7.7.7.7/24
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--Digit Type
    ${name}    set variable    test_digit_type
    ${type}    set variable    num
    ${informationType}    set variable    端口
    ${group_name}    set variable    "/信息管理/数字类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    10811
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建数字类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    10822
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--String Value Type
    ${name}    set variable    test_string_compare
    ${type}    set variable    string
    ${informationType}    set variable    字符串比较
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_string.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建字符类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    test_string_modify.com
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--String 正则部分匹配
    ${name}    set variable    test_partRegx
    ${type}    set variable    string
    ${informationType}    set variable    正则部分匹配
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_string_partRegx.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建字符类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    test_partRegx_modify.com
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--String 正则全匹配
    ${name}    set variable    test_AllRegx
    ${type}    set variable    string
    ${informationType}    set variable    正则全匹配
    ${group_name}    set variable    "/信息管理/字符类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    test_string_allRegx.com
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建字符类值的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${len}    get length    ${list_group}
    should not be empty    ${list_group}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    ${content_mod}    set variable    test_allRegx_modify.com
    &{data}    create dictionary    groupId=${groupId}    content=${content_mod}    contentType=${contentType}
    Update Information    ${id}    &{data}    #修改信息
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Modify Information--Time 相对时间
    ${name}    set variable    test_relative_time
    ${type}    set variable    time
    ${informationType}    set variable    相对时间
    ${group_name}    set variable    "/信息管理/时间类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}
    should not be empty    ${list['name']}
    ${list_name}    Get InformationGroup By Name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_name[u'intelligenceType']}
    ${groupId}    set variable    ${list['id']}
    ${content}    OperatingSystem.get file    ./testdata/information/relative_time_info
    ${content_reg1}=    replace string using regexp    ${content}    "groupId":.*?,    "groupId":"${groupId}",
    ${content_reg2}=    replace string using regexp    ${content_reg1}    "typeId":.*?,    "typeId":"${groupId}",
    ${data}=    replace string using regexp    ${content_reg2}    "name":.*?,    "name":"${name}",
    Create Information By FileContent    ${data}    #创建相对时间的信息
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #根据信息组过滤
    should not be empty    ${list_group}
    ${id}    set variable    ${list[0]['id']}
    ${groupId}    set variable    ${list[0]['groupId']}
    #${data}=    replace string using regexp
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Query Information Content
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    5.5.5.100
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    sleep    2
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_group['name']}    \    #校验新增情报
    ${list}    Query by Content    ${content}    #查询
    should not be empty    ${list}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}

Filter Information by Group
    ${name}    set variable    test_ip_type
    ${type}    set variable    ip
    ${informationType}    set variable    IP
    ${group_name}    set variable    "/信息管理/IP类信息"
    ${parentId}=    Get parentId By groupType    ${group_name}    #get parent_id by information type
    ${list}    Create Information Group    ${name}    ${type}    ${parentId}    ${informationType}    #创建信息组
    should not be empty    ${list['name']}
    ${groupId}    set variable    ${list['id']}
    ${content}    set variable    5.5.5.100
    ${contentType}    set variable    single
    &{data}    create dictionary    groupId=${groupId}    content=${content}    contentType=${contentType}
    Create Information By Data    &{data}    #创建IP类值的信息
    sleep    2
    ${list_group}    Get InformationGroup by name    ${name}    #根据信息组名称获取信息
    should not be empty    ${list_group['name']}    \    #校验新增情报
    ${idpath}    set variable    ${list_group['idPath']}
    ${list}    Query by Idpath    ${idpath}    #查询
    should not be empty    ${list}
    : FOR    ${item}    IN    @{list}
    \    Delete Information    ${item['id']}    #逐个删除ip信息
    Delete Information Group    ${name}
    #Export All Security Infomanagment
    #    Export All Information    ${export_security_info_file}

*** Keywords ***
Test Setup
    User Login    ${default_username}    ${default_password}

Test Teardown
    No Operation
    User Logout
