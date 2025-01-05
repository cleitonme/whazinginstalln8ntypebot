#!/bin/bash
#

stack_wordpress() {
  print_banner
  printf "${WHITE} 💻 Instalando Wordpress...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - root << EOF
cd /root
  cat <<[-]EOF > wordpress.yaml
services:
  wordpress:
    image: soulteary/sqlite-wordpress:latest
    container_name: wordpress
    restart: unless-stopped
    volumes:
      - ./data:/var/www/html
    networks:
      - wordpress_rede
    ports:
      - 32800:80

networks:
  wordpress_rede:
    external: false
    name: wordpress_rede
     

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f wordpress.yaml up -d
}

wordpress_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (wordpress)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  wordpress_hostname=$(echo "${wordpress_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/wordpress << 'END'
server {
  server_name $wordpress_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:32800;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled
EOF

  sleep 2
}

system_certbot_wordpress_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando certbot wordpress...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  wordpress_domain=$(echo "${wordpress_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $wordpress_domain
EOF

  sleep 2
}

system_success_wordpress() {

  print_banner
  printf "${GREEN} 💻 Instalação concluída...${NC}"
  printf "${CYAN_LIGHT}";
  printf "\n\n"
  printf "\n"
  printf "URL Wordpress: https://$wordpress_url"
  printf "\n"
  printf "\n"
  printf "${NC}";

  sleep 2
}