map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

#proxy
upstream proxy_paas_20171017100650 {
    server 127.0.0.1:7000;
    keepalive 2000;
}
upstream proxy_iot_20171017100650 {
    server 127.0.0.1:6000;
    keepalive 2000;
}

upstream proxy_paas_20171017100651 {
    server 127.0.0.1:7001;
    keepalive 2000;
}
upstream proxy_iot_20171017100651 {
    server 127.0.0.1:6001;
    keepalive 2000;
}

upstream proxy_paas_20171017100652 {
    server 127.0.0.1:7002;
    keepalive 2000;
}
upstream proxy_iot_20171017100652 {
    server 127.0.0.1:6002;
    keepalive 2000;
}

upstream proxy_map {
    server 127.0.0.1:8234;
    keepalive 2000;
}

server {
    listen 8000;
#    if ($host = '120.193.171.109') {
#        rewrite ^/(.*)$ http://120.193.171.109/$1 permanent;
#    }
    if ($request_uri ~ ^/home/login$) {
        rewrite ^/(.*)$ http://120.193.171.109:8000/home/centerlogin;
    }
    location / {
        proxy_set_header Host $host:$server_port;
	if ($request_uri ~ ^/ayMap){
            rewrite /ayMap/(.+) /$1;
	    proxy_pass http://proxy_map;
	    break;
        }
        if ($request_uri ~ /webservices\/(\w+)/) {
            set $saas $1;
        }
        #iot page
        if ($request_uri ~ ^(/$|/home|/device|/config|/gisservice|/noticepanel|/video|/visual|/components/sewise/|/upload/(\w+)/video/)) {
            set $saas "iot";
        }

        #api
        if ($request_uri ~ ^/api/(config/collect|config/video|device|translatedata|visual|gisservice|video|wuyou)) {
            set $saas "iot";
        }

        #api2
        if ($request_uri ~ ^/api2/(device|home/message|home/getdatacenterpic|home/productversion|home/projectent|iotapkdownload)) {
            set $saas "iot";
        }

        if ($saas = "iot") {
            proxy_pass http://proxy_iot_20171017100650;
            break;
        }
        proxy_pass http://proxy_paas_20171017100650;
    }
}


server {
    listen 8001;

    location / {
        proxy_set_header Host $host:$server_port;

        #iot api
        if ($request_uri ~ ^/api/(config/collect|config/video|device|translatedata|visual|gisservice|video|wuyou)) {
            set $saas "iot";
        }

        #api2
        if ($request_uri ~ ^/api2/(device|home/getdatacenterpic|home/productversion|home/projectent|iotapkdownload)) {
            set $saas "iot";
        }
        if ($saas = "iot") {
            proxy_pass http://proxy_iot_20171017100651;
            break;
        }

        proxy_pass http://proxy_paas_20171017100651;
    }
}


server {
    listen 6002;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_iot_20171017100652;
    }
}

server {
    listen 7002;
    error_log /var/log/nginx/static.ayiot.com.cn-error.log error;
    access_log /var/log/nginx/static.ayiot.com.cn-access.log combined;

    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_paas_20171017100652;
    }
}




##iot
server {
  listen 6000;
  root /var/www/www.51boshi.com.cn/public;
  location /global/svgweb/ {
      break;
  }
  location /ClientBin/Config/Plat.xml {
      break;
  }
  location /global/pdf2swf/ {
      break;
  }
  location /components/sewise/ {
      break;
  }
  location ~ ^/upload/.*/video/ {
      root /var/www/www.51boshi.com.cn;
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
 # if ($request_uri ~ ^/home/login$) {
 #     #rewrite ^/(.*)$ http://120.193.171.109/;
 # }
  location ~ \.php$ {
      fastcgi_pass   127.0.0.1:9000;
      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      fastcgi_param  ENV  development;
      include        fastcgi_params;
  }
}

server {
    listen 6001;
    root /var/www/www.ayiot.com.cn/public;
    location /crossdomain.xml {
        break;
    }
    location / {
        rewrite . /index.php;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param  ENV  development;
        include        fastcgi_params;
    }
}

server {
    listen 6002;
    root /var/www/www.51boshi.com.cn/public;
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
}

server {
   listen 8234;
   root /var/www/AYMap;

    location / {
       access_log off;
    }
}
