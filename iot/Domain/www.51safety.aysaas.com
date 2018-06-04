map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

#proxy
upstream proxy_paas_20171017100653 {
    server 10.25.1.13:8081;
    keepalive 2000;
}

upstream proxy_iot_20171017100653 {
    server 127.0.0.1:8233;
    keepalive 2000;
}

upstream proxy_map {
    server 127.0.0.1:8234;
    keepalive 2000;
}

server {
    listen 80;
    server_name iot.51safety.com.cn;
    return 301 http://www.ayiot.com.cn$request_uri;
}

server {
    listen 80;
    server_name www.ayiot.com.cn ayiot.com.cn ;
    error_log /var/log/nginx/www.ayiot.com.cn-error.log error;
    access_log /var/log/nginx/www.ayiot.com.cn-access.log combined;

#    if ($host = 'ayiot.com.cn') {
#        rewrite ^/(.*)$ http://www.ayiot.com.cn/$1 permanent;
#    }

    if ($request_uri ~ ^/home/login$) {
        rewrite ^/(.*)$ http://www.ayiot.com.cn/home/centerlogin;
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
        if ($request_uri ~ ^(/$|/home|/device|/config|/gisservice|/noticepanel|/video|/visual|/components/sewise/|/upload/(\w+)/video/|/.well-known)) {
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
            proxy_pass http://proxy_iot_20171017100653;
            break;
        }
        proxy_pass http://proxy_paas_20171017100653;
    }
}

server {
    listen 80;
    server_name fileio.ayiot.com.cn;
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
            proxy_pass http://proxy_iot_20171017100653;
            break;
        }

        proxy_pass http://proxy_paas_20171017100653;
    }
}

server {
    listen 80;
    server_name static-iot.ayiot.com.cn;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_iot_20171017100653;
    }
}

server {
    listen 80;
    server_name static.ayiot.com.cn;
       error_log /var/log/nginx/static.ayiot.com.cn-error.log error;
       access_log /var/log/nginx/static.ayiot.com.cn-access.log combined;

    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_paas_20171017100653;
    }
}


#iot
server {
  listen 8233;
  server_name www.ayiot.com.cn;
  root /var/www/www.ayiot.com.cn/public;

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
  location /.well-known/ {
      break;
  }
  location ~ ^/upload/.*/video/ {
      root /var/www/www.ayiot.com.cn;
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
}

server {
    listen 8233;
    server_name fileio.ayiot.com.cn;
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
        include        fastcgi_params;
    }
}

server {
    listen 8233;
    server_name static-iot.ayiot.com.cn;
    root /var/www/www.ayiot.com.cn/public;

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
  server_name www.ayiot.com.cn;
   root /var/www/AYMap;

    location / {
       access_log off;
    }
}

