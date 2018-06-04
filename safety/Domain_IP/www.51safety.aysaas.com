#proxy
upstream proxy_paas_20180118201214 {
    server 192.168.0.244:23007;    
    keepalive 2000;
}

upstream proxy_safety_20180118201214 {
    server 127.0.0.1:8233;
    keepalive 2000;
}

server {
    listen 23008;
    server_name www.demo.tcaqsc.aysaas.com;
    location / {
        proxy_set_header Host $host:$server_port;

        if ($request_uri ~ /webservices\/(\w+)/) {
            set $saas $1;
        }

        #safety
        if ($request_uri ~ ^(/$|/\?|/home/autoindex|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional)) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_20180118201214;
            break;
        }

        proxy_pass http://proxy_paas_20180118201214;
    }
}

server {
    listen 23008;
    server_name fileio.demo.tcaqsc.aysaas.com;
    location / {
        proxy_set_header Host $host:$server_port;

        #safety
        if ($request_uri ~ ^(/$|/\?|/home/message|/api2/home|/sysop/config|/news|/professional|/api/professional)) {
            set $saas "safety";
        }
        if ($saas = "safety") {
            proxy_pass http://proxy_safety_20180118201214;
            break;
        }

        proxy_pass http://proxy_paas_20180118201214;
    }
}

server {
    listen 23008;
    server_name staticsafety.demo.tcaqsc.aysaas.com;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_safety_20180118201214;
    }
}

server {
    listen 23007;
    server_name static.demo.tcaqsc.aysaas.com;
    location / {
        proxy_set_header Host $host:$server_port;
        proxy_pass http://proxy_paas_20180118201214;
    }
}


#safety
server {
  listen 8233;
  server_name www.demo.tcaqsc.aysaas.com;
  root /var/www/www.demo.tcaqsc.aysaas.com/public;

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
      rewrite ^/(.*)$ https://www.51safety.com.cn/;
  }

  location ~ \.php$ {
      fastcgi_pass   127.0.0.1:9000;
      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      include        fastcgi_params;
  }
}

server {
    listen 8233;
    server_name fileio.demo.tcaqsc.aysaas.com;
    root /var/www/www.demo.tcaqsc.aysaas.com/public;

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
    server_name staticsafety.demo.tcaqsc.aysaas.com;
    root /var/www/www.demo.tcaqsc.aysaas.com/public;

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
