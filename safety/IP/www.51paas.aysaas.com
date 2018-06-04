map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 7000;
    root /var/www/www.51paas.aysaas.com/paas/public;
    error_log /var/log/nginx/www.51paas.com.cn-error.log error;
    access_log /var/log/nginx/www.51paas.com.cn-access.log combined;
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
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }
}

server {
    listen 7002;
    root /var/www/www.51paas.aysaas.com/paas/public;
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
    root /var/www/www.51paas.aysaas.com/paas/public;
    error_log /var/log/nginx/fileio.51paas.com.cn-error.log error;
    access_log /var/log/nginx/fileio.51paas.com.cn-access.log combined;
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

server {
    listen 7003;
    root /var/www/node_51paas/public/dist ;
    error_log /var/log/nginx/Node-51paas-error.log error;
    access_log /var/log/nginx/Node-51paas-access.log combined;
    location ~* \.(eot|ttf|woff|woff2)$ {
        add_header Access-Control-Allow-Origin *;
    }
}
