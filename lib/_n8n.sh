#!/bin/bash
#


postgresql_n8n() {
  print_banner
  printf "${WHITE} 💻 Configurando Postgresql...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2


sudo su - root << EOF
cd /root
  cat <<[-]EOF > postgresqln8n.yaml
services:
  postgres:
    container_name: postgresqln8n
    image: postgres:latest
    restart: always
    environment:
      - POSTGRES_PASSWORD=Admin33Admin77
    networks:
      - n8n_rede
      - bridge
    volumes:
      - postgres_n8n:/var/lib/postgresql/data
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1024M

volumes:
  postgres_n8n:
    external: false
    name: postgres_n8n

networks:
  n8n_rede:
    external: false
    name: n8n_rede
  bridge:
    external: true

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f postgresqln8n.yaml up -d
}


stack_n8n() {
  print_banner
  printf "${WHITE} 💻 Instalando N8N...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

n8n_hostname=$(echo "${n8n_url/https:\/\/}")

sudo su - root << EOF
cd /root
  cat <<[-]EOF > n8n.yaml
services:
  n8n:
    container_name: n8n
    image: n8nio/n8n
    restart: always
    networks:
      - n8n_rede
    ports:
      - 5678:5678
    volumes:
      - n8n_data:/data
    environment:
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=Admin33Admin77
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=postgres
      - DB_POSTGRESDB_HOST=postgres
      - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      - N8N_HOST=$n8n_hostname
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://$n8n_hostname/	  
      - N8N_RELEASE_TYPE=stable
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
volumes:
  n8n_data:
    external: false
    name: n8n_data

networks:
  n8n_rede:
    external: false
    name: n8n_rede

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f n8n.yaml up -d
}

n8n_caddy_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando Caddy (n8n)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  n8n_hostname=$(echo "${n8n_url/https:\/\/}")

  sudo su - root << EOF

cat >> /etc/caddy/Caddyfile << END

# --- n8n ---
$n8n_hostname {
  reverse_proxy 127.0.0.1:5678
    request_body {
        max_size 200MB
    }
}
END

EOF

  sleep 2
}

n8n_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (n8n)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  n8n_hostname=$(echo "${n8n_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/n8n << 'END'
server {
  server_name $n8n_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:5678;
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

ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled
EOF

  sleep 2
}

system_certbot_n8n_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  n8n_domain=$(echo "${n8n_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $n8n_domain
EOF

  sleep 2
}

system_success_n8n() {

  print_banner
  printf "${GREEN} 💻 Instalação concluída...${NC}"
  printf "${CYAN_LIGHT}";
  printf "\n\n"
  printf "\n"
  printf "URL N8N: https://$n8n_url"
  printf "\n"
  printf "\n"
  printf "${NC}";

  sleep 2
}