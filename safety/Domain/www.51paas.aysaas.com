map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {

    listen 8080;

    server_name tools.51safety.com.cn;

    root /var/www/paas/public;

    error_log /var/log/nginx/paas.51safety.com.cn-error.log error;

    access_log /var/log/nginx/paas.51safety.com.cn-access.log combined;

    location /components/ClientBin/Config/Plat.xml {
        break;
    }


    location /global/jquery/extend/uploadify/ {
        break;
    }


    location /components/ueditor/ {
        break;
    }

  #    location = /home/login  {
  #      return 302 https://www.51safety.com.cn/auth/login;
  #  }

    location /favicon.ico {
        break;
        access_log off;
        log_not_found off;
    }

        location /robots.txt {
            break;
            access_log off;
            log_not_found off;
        }

        location /apple-touch-icon-precomposed.png {
            break;
            access_log off;
            log_not_found off;
        }

        location /apple-touch-icon.png {
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

    location /api/apk/GetApk {
        rewrite . /index.php?ent=51safety;
    }

    location /api2/apkdownload {
        rewrite . /index.php?ent=51safety;
    }
        location ~ ^/common {
           proxy_redirect off;
           proxy_set_header   Host   $host;
           proxy_set_header   X-Real-IP  $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   Accept-Encoding "gzip";
           proxy_pass http://nodesafety;
       }

      # 应用中心
       location ~ ^/appcenter(?!\/appsystem) {
           proxy_redirect off;
           proxy_set_header   Host   $host;
           proxy_set_header   X-Real-IP  $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   Accept-Encoding "gzip";
           proxy_pass http://nodesafety;
      }

        location ~ ^/organization(?!\/(contacts|manage)) {
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Accept-Encoding "gzip";
                proxy_pass http://nodesafety;
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
	if ($request_uri ~ "^/service_org") {
	     proxy_pass http://10.27.237.137:8070$request_uri;
        }
        fastcgi_pass   127.0.0.1:9001;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }
}

server {

    listen 8080;

    server_name static-tools.51safety.com.cn;

    root /var/www/paas/public;

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

    listen 8080;

    server_name fileio-tools.51safety.com.cn;

    root /var/www/paas/public;

    error_log /var/log/nginx/paas.51safety.com.cn-error.log error;

    access_log /var/log/nginx/paas.51safety.com.cn-access.log combined;

    client_max_body_size 64m;

    location /crossdomain.xml {
        break;
    }



    location / {
        rewrite . /index.php;
    }

    location ~ \.php$ {
          if ($request_uri ~ "^/service_org") {
            proxy_pass http://10.27.237.137:8070$request_uri;
          }
        fastcgi_pass   127.0.0.1:9001;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }

}

server {

    listen 8080;

    server_name fileio.51safety.com.cn;

    root /var/www/paas/public;

    error_log /var/log/nginx/fileio.51safety.com.cn-error.log error;

    access_log /var/log/nginx/fileio.51safety.com.cn-access.log combined;

    client_max_body_size 64m;

    location /crossdomain.xml {
        break;
    }



    location / {
        rewrite . /index.php;
    }

    location ~ \.php$ {
	  if ($request_uri ~ "^/service_org") {
            proxy_pass http://10.27.237.137:8070$request_uri;
          }
        fastcgi_pass   127.0.0.1:9001;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV production;
        include        fastcgi_params;
    }

}


server {

    listen 443;

    server_name websocket-tools.51safety.com.cn;

    ssl on;
    ssl_certificate /etc/ssl/certs/51safety.com.cn.crt;
    ssl_certificate_key /etc/ssl/private/51safety.com.cn.key;

    location / {
        proxy_pass http://127.0.0.1:3232;
        proxy_http_version 1.1;
        proxy_read_timeout 86400;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
