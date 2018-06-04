<?php

return [

    'application_name' => 'AYSaaS-tcaqsc',

    'title' => '太仓市安全生产监管信息系统及指挥监控中心项目',

    'desc' => '太仓市安全生产监管信息系统及指挥监控中心项目',

    'keywords' => '云 协作平台 云办公 大数据 SaaS 应用平台 开放平台',

    'is_debug' => false,

    'is_testing_api' => false,

    'is_accrual' => true,

    'is_project' => false,

    'skip_identity' => true,

    'root_domain' => 'demo.tcaqsc.aysaas.com',

    'www_domain' => 'www.demo.tcaqsc.aysaas.com:23008',

    'static_domain' => 'staticsafety.demo.tcaqsc.aysaas.com:23008',

    'fileio_domain' => 'fileio.demo.tcaqsc.aysaas.com:23008',

    'update_domain' => 'update.demo.tcaqsc.aysaas.com:23008',

    'socket_domain' => 'ws://www.demo.tcaqsc.aysaas.com:3232',

    'preview_domain' => 'dp.qycloud.com.cn/op/view.aspx?src=',//https://view.officeapps.live.com/op/view.aspx?src=

    'appstore_lookup' => 'http://itunes.apple.com/lookup?id=1067718664',    //ios官方更新地址

    'appstore_page' => 'https://itunes.apple.com/us/app/qi-ye-yun/id1067718664?l=zh&ls=1&mt=8', //ios官方安装页面

    'is_notice' => true,

    'notice_email' => [
        '1125851000@qq.com' // 因邮件发送问题，队列提醒暂不起作用
    ],

    'is_solor' => false,

    'useGa' => false, //是否启用GoogleAnalytics

    'useBw' => false, //是否启用服务器监控

    'gaAccount' => '', //GoogleAnalytics跟踪帐号(测试可以用：UA-54849734-1)

    'menu_obj' => [
        '/api/message/menu' => '站内短信',
        '/api/store/menu' => '文档管理'
    ],


    'errorLog'  => true,

    'errorReport' => false,

    'migration_init_version' => '20120822094445', //初始化版本

    'migration_initdata_version' => '20120822110225', //初始化数据版本

    'migration_limit_version' => '', //从这个版本开始

    'migration_checkTplTable' => true,    //是否检查企业与模版表的差异

    'open_menu_permission' => true, //是否开启新版菜单权限配置功能

    'open_admin_config' => true, //config模块管理员工具
    'useSSL' => false,
    'is_check' => true,

    'arrearage_disable' => false, //欠费企业是否停用

    'is_socket' => false, //是否开启websocket

    'is_socket_debug' => false,

    'is_badjs' => false, //是否开启badjs上报

    'is_dbcache' => false, //是否数据缓存

    'baidu_mapkey' => 'cMURp5Iy4EFGdGslu4VofGsVUj6zyZ2j',

    'monitor_log' => false,

    //融云秘钥
    'RongCloud_AppKey' => 'vnroth0kr9y0o',
    'RongCloud_AppSecret' => '0YAD8OBGAcggD',
    //美恰ID
    'meiQiaSystemId' => 53093,

    'showOutCustomer' => true,

    // 工作台新手引导
    'is_lead' => true,
];
