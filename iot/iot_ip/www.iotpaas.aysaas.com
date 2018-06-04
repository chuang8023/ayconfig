map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 7000;
    root /var/www/www.iotpaas.com.cn/saas/public;
    error_log /var/log/nginx/www.iotpaas.com.cn-error.log error;
    access_log /var/log/nginx/www.iotpaas.com.cn-access.log combined;
    location /websocket/ {
        proxy_pass http://127.0.0.1:3232;
        proxy_http_version 1.1;
        proxy_read_timeout 86400;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
    location /components/ClientBin/Config/Plat.xml {
        break;
    }
    location /global/jquery/extend/uploadify/ {
        break;
    }
    location /components/ueditor/ {
        break;
    }
    location /favicon.ico {
        break;
        access_log off;
        log_not_found off;
    }
    location / {
        rewrite . /index.php;
    }
    location /webservices/ {
        rewrite . /services.php;
    }
    location /components/gismap/ {
       break;
    }
     location ^~/eai/gismap/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://192.168.0.209:8382/gsws_new/;
        proxy_cookie_path /dgws/ /;
        proxy_cookie_domain off;
        proxy_cookie_domain www.$host $host;
        proxy_redirect off;
  }
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }
}

server {
    listen 7002;
    root /var/www/www.iotpaas.com.cn/saas/public;
    location / {
        access_log off;
    }
    location ~ \.php$ {
        deny all;
    }
    location ~* \.(eot|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }
     location /form/render/ueditor/ {
        rewrite ^/form/render/ueditor/(.*)$ /components/ueditor/$1 permanent;
    }
}


server {
    listen 7001;
    root /var/www/www.iotpaas.com.cn/saas/public;
    error_log /var/log/nginx/fileio.iotpaas.com.cn-error.log error;
    access_log /var/log/nginx/fileio.iotpaas.com.cn-access.log combined;
    client_max_body_size 64m;
    location /crossdomain.xml {
        break;
    }
    location / {
        rewrite . /index.php;
    }
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }
}

server {
    listen 3232;
    location / {
        proxy_pass http://127.0.0.1:3232;
        proxy_http_version 1.1;
        proxy_read_timeout 86400;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
