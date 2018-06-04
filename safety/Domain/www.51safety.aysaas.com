map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

#proxy
upstream proxy_paas_20170926202430 {
    server 10.25.1.13:8080;
    keepalive 2000;
}

upstream proxy_safety_20170926202430 {
    server 127.0.0.1:8233;
    keepalive 2000;
}



server {
    server_name tools.51safety.com.cn;
    
    error_log /var/log/nginx/tools.51safety.com.cn-error.log error;
   access_log /var/log/nginx/tools.51safety.com.cn-access.log combined;


#    location = /websocket/ {
#        proxy_pass http://127.0.0.1:3232;
#        proxy_http_version 1.1;
#        proxy_read_timeout 86400;
#        proxy_set_header Upgrade $http_upgrade;
#        proxy_set_header Connection "Upgrade";
#    }

    location / {
        proxy_set_header Host $host:$server_port;
        proxy_set_header   X_FORWARDED_FOR  $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;

        if ($request_uri ~ /webservices\/(\w+)/) {
            set $saas $1;
        }

        #临时添加
        if ($request_uri ~ ^/api2/home/page) {
            proxy_pass http://proxy_paas_20170926202430;
            break;
        }

        #safety
        if ($request_uri ~ ^(/$|/\?|/home/autoindex|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional|/api2/chat/chat/GeAppVersion)) {
            set $saas "safety";
        }
        if ($request_uri = /favicon.ico) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_20170926202430;
            break;
        }
	 #iot page
        if ($request_uri ~ ^(/$|/device|/gisservice|/noticepanel|/video|/visual)) {
            set $saas "iot";
        }
        #api
        if ($request_uri ~ ^/api/(config/collect|config/video|device|translatedata|visual|gisservice|video|wuyou)) {
            set $saas "iot";
        }

        #api2
        if ($request_uri ~ ^/api2/(device|home/getdatacenterpic|home/productversion|home/projectent|iotapkdownload)) {
            set $saas "iot";
        }

        if ($saas = "iot") {
            proxy_pass http://proxy_iot_20171028123639;
            break;
        }

        proxy_pass http://proxy_paas_20170926202430;

    }

    if ($request_uri ~ ^/home/login$) {
        rewrite ^/(.*)$ https://www.51safety.com.cn/auth/login;
    }
    
     location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
        error_log /var/log/nginx/safety_online.error error;
        access_log /var/log/nginx/safety_online.access combined;
    }


}

server {
    server_name fileio.51safety.com.cn;
    location / {
        proxy_set_header Host $host:$server_port;
        #safety
        if ($request_uri ~ ^(/$|/\?|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional)) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_20170926202430;
            break;
        }
	 #iot api
        if ($request_uri ~ ^/api/(config/collect|config/video|device|translatedata|visual|gisservice|video|wuyou)) {
            set $saas "iot";
        }

        #api2
        if ($request_uri ~ ^/api2/(device|home/getdatacenterpic|home/productversion|home/projectent|iotapkdownload)) {
            set $saas "iot";
        }
        if ($saas = "iot") {
            proxy_pass http://proxy_iot_20171028123639;
            break;
        }
        proxy_set_header Host fileio-tools.51safety.com.cn:$server_port;
        proxy_pass http://proxy_paas_20170926202430;
    }
     location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
        error_log /var/log/nginx/safety_online.error error;
        access_log /var/log/nginx/safety_online.access combined;
    }
}


server {
    server_name  static.51safety.com.cn;


    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_safety_20170926202430/;
    }
   
    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
        error_log /var/log/nginx/safety_online.error error;
        access_log /var/log/nginx/safety_online.access combined;

    }

}

server {
    server_name statictoolsiot.51safety.com.cn;


    error_log /var/log/nginx/statictoolsiot.51safety.com.cn-error.log error;
    access_log /var/log/nginx/statictoolsiot.51safety.com.cn-access.log combined;

    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_iot_20171028123639;
    }
   
    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
        error_log /var/log/nginx/safety_online.error error;
        access_log /var/log/nginx/safety_online.access combined;

    }

}

server {
    server_name static-tools.51safety.com.cn;


    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_paas_20170926202430/;
    }

    location /mixed/ {
        proxy_set_header Host static.51safety.com.cn:$server_port;
        proxy_pass http://proxy_safety_20170926202430;
    }

    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
        error_log /var/log/nginx/safety_online.error error;
        access_log /var/log/nginx/safety_online.access combined;

    }

}


#safety
server {
  listen 8233;
  server_name tools.51safety.com.cn;
  root /var/www/www.51safety.com.cn/public;
   
   error_log /var/log/nginx/tools.51safety.com.cn-error.log error;
   access_log /var/log/nginx/tools.51safety.com.cn-access.log combined;

  location /global/svgweb/ {
      break;
  }

  location /ClientBin/Config/Plat.xml {
      break;
  }

  location /global/pdf2swf/ {
      break;
  }

  location /components/ueditor/ {
      break;
  }

  location /global/jquery/extend/uploadify/ {
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

   location /api2/chat/chat/GeAppVersion {
        rewrite (.*) /index.php?$1&ent=anquanwuyouwangyunwe;
   }

  if ($request_uri ~ ^/home/login$) {
#      rewrite ^/(.*)$ https://www.51safety.com.cn/;
  }

  location ~ \.php$ {
      fastcgi_pass   127.0.0.1:9000;
      fastcgi_param ENV production;
      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      include        fastcgi_params;
  }

  location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
    }

}

#iot
server {
  listen 8235;
  server_name tools.51safety.com.cn;
  root /home/database/www.iot.com.cn/public;

  location /global/svgweb/ {
      break;
  }

  location /ClientBin/Config/Plat.xml {
      break;
  }

  location /global/pdf2swf/ {
      break;
  }

  location /components/ueditor/ {
      break;
  }

  location /global/jquery/extend/uploadify/ {
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

  if ($request_uri ~ ^/home/login$) {
      #rewrite ^/(.*)$ https://www.iot.com.cn/;
  }

  location ~ \.php$ {
      fastcgi_pass   127.0.0.1:9000;
      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      include        fastcgi_params;
  }

  location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
    }


}



server {
    listen 8233;
    server_name fileio.51safety.com.cn;
    root /var/www/www.51safety.com.cn/public;

    location /crossdomain.xml {
        break;
    }

    location / {
        rewrite . /index.php;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param ENV production;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
	
    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
    }

}

server {
    listen 8233;
    server_name static.51safety.com.cn;
    root /var/www/www.51safety.com.cn/public;

    location ~ \.php$ {
        deny all;
    }

    location / {
       access_log off;
    }

    location ~* \.(eot|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }

    location /form/render/ueditor/ {
        rewrite ^/form/render/ueditor/(.*)$ /components/ueditor/$1 permanent;
    }

    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
    }

}

server {
    listen 8235;
    server_name statictoolsiot.51safety.com.cn;
    root /home/database/www.iot.com.cn/public;

    location ~ \.php$ {
        deny all;
    }

    location / {
       access_log off;
    }

    location ~* \.(eot|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }

    location /form/render/ueditor/ {
        rewrite ^/form/render/ueditor/(.*)$ /components/ueditor/$1 permanent;
    }

    location ^~/eai/project/ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://10.46.69.201:8090/safety-online-SNAPSHOT/;
        #proxy_cookie_path /safety-online-SNAPSHOT/ /;
        proxy_redirect off;
    }

}
