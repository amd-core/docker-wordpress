sudo docker stop amd-wordpress
sudo docker rm amd-wordpress

sudo docker run \
  -p 8080:80 \
  -v /var/log/nginx:/var/log/nginx \
  --name amd-wordpress \
  -e DB_NAME="amd_wordpress" \
  -e DB_USER="amd_wordpress_user" \
  -e DB_PASSWORD="amd_wordpress_password" \
  --link amd-mariadb:mysql \
  -d \
  amd-wordpress
