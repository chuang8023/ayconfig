<?php

return [

    'application_name' => 'AYSaaS-hbzhaj',
    'title' => '湖北省安全生产监督管理局全国安全生产“一张图”建设项目',
    'desc' => '湖北省安全生产监督管理局全国安全生产“一张图”建设项目',
    'keywords' => '湖北省安全生产监督管理局全国安全生产“一张图”建设项目',
    'is_debug' => true,

    'is_accrual' => true,

    'is_project' => true,

    'skip_identity' => true,

    'root_domain' => '223.75.53.98',

    'www_domain' => '223.75.53.98:8000',

    'static_domain' => '223.75.53.98:6002',

    'fileio_domain' => '223.75.53.98:8000',

    'update_domain' => '223.75.53.98:8004',

    'socket_domain' => 'ws://www.master.aysaas.com:3232',

    'preview_domain' => 'dp.qycloud.com.cn/op/view.aspx?src=',//https://view.officeapps.live.com/op/view.aspx?src=

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
];
