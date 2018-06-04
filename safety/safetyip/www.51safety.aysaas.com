map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

#proxy
upstream proxy_paas_201803051926 {
    server 127.0.0.1:7000;
    keepalive 2000;
}
upstream proxy_safety_201803051926 {
    server 127.0.0.1:6000;
    keepalive 2000;
}

upstream proxy_paas_201803051927 {
    server 127.0.0.1:7001;
    keepalive 2000;
}
upstream proxy_safety_201803051927 {
    server 127.0.0.1:6001;
    keepalive 2000;
}

upstream proxy_paas_201803051928 {
    server 127.0.0.1:7002;
    keepalive 2000;
}
upstream proxy_safety_201803051928 {
    server 127.0.0.1:6002;
    keepalive 2000;
}


server {
    listen 8000;
    error_log /var/log/nginx/www.51safety.aysaas.com-error.log error;
    access_log /var/log/nginx/www.51safety.aysaas.com-access.log combined;
    location / {
        proxy_set_header Host $host:$server_port;
        if ($request_uri ~ /webservices\/(\w+)/) {
            set $saas $1;
        }
        #safety
        if ($request_uri ~ ^(/$|/\?|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional)) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_201803051926;
            break;
        }
        proxy_pass http://proxy_paas_201803051926;
    }
}

server {
    listen 8001;
    error_log /var/log/nginx/fileio.51safety.aysaas.com-error.log error;
    access_log /var/log/nginx/fileio.51safety.aysaas.com-access.log combined;
    location / {
        proxy_set_header Host $host:$server_port;
        #safety
        if ($request_uri ~ ^(/$|/\?|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional)) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_201803051927;
            break;
        }
        proxy_pass http://proxy_paas_201803051927;
    }
}

server {
    listen 6002;
    error_log /var/log/nginx/staticsafety.51safety.aysaas.com-error.log error;
    access_log /var/log/nginx/staticsafety.51safety.aysaas.com-access.log combined;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_safety_201803051928/;
    }
}

server {
    listen 7002;
    error_log /var/log/nginx/static.51safety.aysaas.com-error.log error;
    access_log /var/log/nginx/static.51safety.aysaas.com-access.log combined;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_paas_201803051928/;
    }
}


#safety
server {
  listen 6000;
  root /var/www/www.51safety.aysaas.com/public;
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
  #if ($request_uri ~ ^/home/login$) {
  #    rewrite ^/(.*)$ https://www.51safety.com.cn/;
  #}
  location ~ \.php$ {
      fastcgi_pass   127.0.0.1:9000;
      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      fastcgi_param   ENV production;
      include        fastcgi_params;
  }
}

server {
    listen 6001;
    server_name fileio.51safety.aysaas.com;
    root /var/www/www.51safety.aysaas.com/public;
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
    listen 6002;
    root /var/www/www.51safety.aysaas.com/public;
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
