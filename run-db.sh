sudo docker stop amd-mariadb
sudo docker rm amd-mariadb

sudo docker run \
  -p 3306:3306 \
  -v amd-mariadb:/var/lib/mysql \
  --name amd-mariadb \
  -e MYSQL_DATABASE="amd_wordpress" \
  -e MYSQL_USER="amd_wordpress_user" \
  -e MYSQL_PASSWORD="amd_wordpress_password" \
  -e MYSQL_ROOT_PASSWORD="amd_root_password" \
  -d \
  mariadb
