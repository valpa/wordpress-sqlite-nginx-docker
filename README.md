## Wordpress on Nginx using Sqlite instead of MySQL Dockerfile

This repository contains **Dockerfile** of cn-ZH Wordpress on Nginx using Sqlite instead of MySQL


### Usage

```
docker build -t="valpa/wordpress-sqlite-nginx-docker" github.com/valpa/wordpress-sqlite-nginx-docker
mkdir -p ./wordpress/database ./wordpress/uploads 
docker run -d -p 3000:80 -v ./wordpress/database:/var/wordpress/database -v ./wordpress/uploads:/usr/share/nginx/html/wp-content/uploads valpa/wordpress-sqlite-nginx-docker
```    

After few seconds, open `http://<host>` to see the wordpress install page.
    
