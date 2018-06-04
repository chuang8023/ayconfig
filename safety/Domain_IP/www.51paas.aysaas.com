server {
    
    listen 23007;
    
    server_name www.demo.tcaqsc.aysaas.com;

    root /var/www/www.demo.paas.aysaas.com/paas/public;

    error_log /var/log/nginx/www.demo.paas.aysaas.com-error.log error;

    access_log /var/log/nginx/www.demo.paas.aysaas.com-access.log combined;

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
	if ($request_uri ~ "^/service_org") {
           root /var/www/www.demo.paas.aysaas.com/org/public;
        }
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV development;
        include        fastcgi_params;
    }
    
      location ~ ^/common {
           proxy_redirect off;
           proxy_set_header   Host   $host;
           proxy_set_header   X-Real-IP  $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   Accept-Encoding "gzip";
           proxy_pass http://node_tc;
       }

       # 应用中心
       location ~ ^/appcenter(?!\/appsystem) {
           proxy_redirect off;
           proxy_set_header   Host   $host;
           proxy_set_header   X-Real-IP  $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   Accept-Encoding "gzip";
           proxy_pass http://node_tc;
       }
     #组织架构
        location ~ ^/organization(?!\/(contacts|manage)) {
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Accept-Encoding "gzip";
                proxy_pass http://node_tc;
        }

}

server {
    
    listen 23007;
    
    server_name static.demo.tcaqsc.aysaas.com;

    root /var/www/www.demo.paas.aysaas.com/paas/public;

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
    
    listen 23007;
    
    server_name fileio.demo.tcaqsc.aysaas.com;

    root /var/www/www.demo.paas.aysaas.com/paas/public;

    error_log /var/log/nginx/www.demo.paas.aysaas.com-error.log error;

    access_log /var/log/nginx/www.demo.paas.aysaas.com-access.log combined;

    client_max_body_size 64m;

    location /crossdomain.xml {
        break;
    }

    

    location / {
        rewrite . /index.php;
    }

    location ~ \.php$ {
	if ($request_uri ~ "^/service_org") {
           root /var/www/www.demo.paas.aysaas.com/org/public;
        }
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param   ENV development;
        include        fastcgi_params;
    }

}

server {
     listen 23007;

     server_name nodestatic.demo.tcaqsc.aysaas.com;

      root /var/www/node_taicang/public/dist;

      location ~* \.(eot|ttf|woff|woff2)$ {
           add_header Access-Control-Allow-Origin *;
      }
}

