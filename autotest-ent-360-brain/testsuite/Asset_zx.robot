*** Settings ***
Documentation     TESTING ASSET MANAGE 360
Test Setup        TestSetup
Test Teardown     TestTeardown
Variables         ../config/config.py
Resource          ../keywords/kw_ent.robot
Resource          ../keywords/kw_asset_zx.robot

*** Variables ***
${local_file}     testdata/asset/asset_zx.xlsx

*** Test Cases ***
Add Tags For Assets
    ##### 为每一个资产添加标签
    ${tag_list1}    create list    test    test1    test2
    ${data}=    Add tag for Asset    asset_ip=192.168.1.1    tags=${tag_list1}
    ${tag_list2}    create list    test    test3    test4
    ${data}=    Add tag for Asset    asset_ip=192.168.1.2    tags=${tag_list2}
    ${tag_list3}    create list    test5    test6
    ${data}=    Add tag for Asset    asset_ip=192.168.1.3    tags=${tag_list3}

Get All Asset Tags
    ##### 查询出资产搜索标签 校验其数量及第一个tag值
    ${data}=    Get All Tags
    length should be    ${data}    7
    should be equal as strings    ${data[0]['name']}    test

Search assets by IP/name/owner
    ###根据IP搜索
    ${data_ip}    Search Asset By Type    general_ip    192.168.1.3
    length should be    ${data_ip}    1
    should be equal as strings    ${data_ip[0]["ip_address"]}    192.168.1.3
    ####根据资产名称搜索
    ${data_name}    Search Asset By Type    asset_name    ftp_server
    length should be    ${data_name}    1
    should be equal as strings    ${data_name[0]["asset_name"]}    ftp_server
    ####根据责任人搜索
    ${data_responsible}    Search Asset By Type    type=responsible_id    value=Tom
    length should be    ${data_responsible}    1
    should be equal as strings    ${data_responsible[0]["responsible_id"]}    Tom

Search assets by Tags And Owner
    ####资产标签与资产负责人联合搜---源数据必须有多个相同负责人-才体现出联合搜索
    ${data}    Search Asset By Type    type=responsible_id    value=Tom    tags=test
    ${list}    create list    test    test3    test4
    length should be    ${data}    1
    should be equal as strings    ${data[0]["responsible_id"]}    Tom
    should be equal as strings    ${data[0]["customer_tags"]}    ${list}
    should be equal as strings    ${data[0]["ip_address"]}    192.168.1.2

Search assets by Tag
    #####仅根据资产标签搜索资产
    ${data_tags}    Search Assets By Tags    tags=test,test1
    length should be    ${data_tags}    2
    ${list0}    create list    test    test1    test2
    ${list1}    create list    test    test3    test4
    should be equal as strings    ${data_tags[0]["customer_tags"]}    ${list0}
    should be equal as strings    ${data_tags[0]["ip_address"]}    192.168.1.1
    should be equal as strings    ${data_tags[1]["customer_tags"]}    ${list1}
    should be equal as strings    ${data_tags[1]["ip_address"]}    192.168.1.2


Import Assets By Skip
    #### 再次导入资产文件，自动选择忽略，测试skip
    ${data}=    Import Assets    ${local_file}
    log    ${data}
    should end with    ${data}    skip

*** Keywords ***
TestSetup
    User Login    ${default_username}    ${default_password}
    Clear Assets
    Import Assets    ${local_file}

TestTeardown
    User Logout
