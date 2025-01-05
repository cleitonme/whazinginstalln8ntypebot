#!/bin/bash
# 
# functions for setting up app backend


postgresql_typebot() {
  print_banner
  printf "${WHITE} 💻 Configurando Postgresql...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2


sudo su - root << EOF
cd /root
  cat <<[-]EOF > postgresqltypebot.yaml
services:
  postgres:
    container_name: postgresqltypebot
    image: postgres:latest
    restart: always
    environment:
      - POSTGRES_PASSWORD=Admin33Admin77
    networks:
      - typebot_rede
    volumes:
      - postgres_typebot:/var/lib/postgresql/data
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
  postgres_typebot:
    external: false
    name: postgres_typebot

networks:
  typebot_rede:
    external: false
    name: typebot_rede

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f postgresqltypebot.yaml up -d
}

script_minio_typebot() {
  print_banner
  printf "${WHITE} 💻 Configurando script Minio...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
  

sudo su - root << EOF
cd /root
  cat <<[-]EOF > minio-init.sh
#!/bin/sh

# Configurações iniciais
MC_ALIAS="local"
BUCKET_NAME="typebot"

# Configurando o cliente mc
mc alias set local http://miniotypebot:9000 minio minio123

# Criar bucket, caso não exista
if ! mc ls local/typebot >/dev/null 2>&1; then
    mc mb local/typebot
    mc anonymous set public local/typebot
    echo "Bucket 'typebot' criado e configurado como público."
else
    echo "Bucket 'typebot' já existe."
fi

[-]EOF
EOF

  sleep 2
  cd /root
  chmod +x minio-init.sh
}

minio_typebot() {
  print_banner
  printf "${WHITE} 💻 Configurando Minio...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
  
minio1_hostname=$(echo "${minio1_url/https:\/\/}")
minio2_hostname=$(echo "${minio2_url/https:\/\/}")


sudo su - root << EOF
cd /root
  cat <<[-]EOF > miniotypebot.yaml
services:
  minio:
    container_name: miniotypebot
    image: minio/minio
    restart: always
    command: server /data --console-address ":9001"
    networks:
      - typebot_rede
    ports:
      - 32771:9000
      - 32772:9001
    volumes:
      - minio_data:/data
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=minio123
      - MINIO_BROWSER_REDIRECT_URL=https://$minio1_hostname
      - MINIO_SERVER_URL=https://$minio2_hostname

  minio-init:
    image: minio/mc
    depends_on:
      - minio
    networks:
      - typebot_rede
    volumes:
      - ./minio-init.sh:/usr/bin/minio-init.sh
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=minio123
    entrypoint: ["/bin/sh", "-c", "sleep 30 && /usr/bin/minio-init.sh"]
    restart: "no"

volumes:
  minio_data:
    external: false
    name: minio_data

networks:
  typebot_rede:
    external: false
    name: typebot_rede

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f miniotypebot.yaml up -d
}

typebotviewer_typebot() {
  print_banner
  printf "${WHITE} 💻 Configurando Typebot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
  
type1_hostname=$(echo "${type1_url/https:\/\/}")
type2_hostname=$(echo "${type2_url/https:\/\/}")  
minio1_hostname=$(echo "${minio1_url/https:\/\/}")
minio2_hostname=$(echo "${minio2_url/https:\/\/}")

sudo su - root << EOF
cd /root
  cat <<[-]EOF > typebotviewer.yaml
services:
  typebot_viewer:
    container_name: typebotviewer
    image: baptistearno/typebot-viewer:latest
    restart: always
    networks:
      - typebot_rede
    ports:
      - 8081:3000
    environment:
      - DATABASE_URL=postgresql://postgres:Admin33Admin77@postgres:5432/postgres
      - ENCRYPTION_SECRET=7Rl2NKGhkMUHRV0dtRg8hD2YNopCrAeH
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED
      - NEXTAUTH_URL=https://$type1_hostname
      - NEXT_PUBLIC_VIEWER_URL=https://$type2_hostname
      - NEXTAUTH_URL_INTERNAL=http://localhost:3000
      - DISABLE_SIGNUP=true
      - ADMIN_EMAIL=${email_end}
      - NEXT_PUBLIC_SMTP_FROM='TypeBot' <${email_end}>
      - SMTP_AUTH_DISABLED=false
      - SMTP_USERNAME=${email_end}
      - SMTP_PASSWORD=${senha_email}
      - SMTP_HOST=${host_smtp}
      - SMTP_PORT=${porta_email}
      - SMTP_SECURE=${smtp_secure}
      # Configurações do Typebot e Google Cloud
      #- GOOGLE_CLIENT_ID=
      #- GOOGLE_CLIENT_SECRET=
      # Configurações do Typebot e Minio
      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$minio2_hostname
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

networks:
  typebot_rede:
    external: false
    name: typebot_rede

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f typebotviewer.yaml up -d
}

typebotbuilder_typebot() {
  print_banner
  printf "${WHITE} 💻 Configurando Typebot Builder...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
  
type1_hostname=$(echo "${type1_url/https:\/\/}")
type2_hostname=$(echo "${type2_url/https:\/\/}")  
minio1_hostname=$(echo "${minio1_url/https:\/\/}")
minio2_hostname=$(echo "${minio2_url/https:\/\/}")

sudo su - root << EOF
cd /root
  cat <<[-]EOF > typebotbuilder.yaml
services:
  typebot_builder:
    container_name: typebotbuilder
    image: baptistearno/typebot-builder:latest
    restart: always
    networks:
      - typebot_rede
    ports:
      - 8080:3000
    environment:
      - DATABASE_URL=postgresql://postgres:Admin33Admin77@postgres:5432/postgres
      - ENCRYPTION_SECRET=7Rl2NKGhkMUHRV0dtRg8hD2YNopCrAeH
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED
      - NEXTAUTH_URL=https://$type1_hostname
      - NEXT_PUBLIC_VIEWER_URL=https://$type2_hostname
      - NEXTAUTH_URL_INTERNAL=http://localhost:3000
      - DISABLE_SIGNUP=true
      - ADMIN_EMAIL=${email_end}
      - NEXT_PUBLIC_SMTP_FROM='TypeBot' <${email_end}>
      - SMTP_AUTH_DISABLED=false
      - SMTP_USERNAME=${email_end}
      - SMTP_PASSWORD=${senha_email}
      - SMTP_HOST=${host_smtp}
      - SMTP_PORT=${porta_email}
      - SMTP_SECURE=${smtp_secure}
      # Configurações do Typebot e Google Cloud
      #- GOOGLE_CLIENT_ID=
      #- GOOGLE_CLIENT_SECRET=
      # Configurações do Typebot e Minio
      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$minio2_hostname
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

networks:
  typebot_rede:
    external: false
    name: typebot_rede

[-]EOF
EOF

  sleep 2
  cd /root
  docker compose -f typebotbuilder.yaml up -d
}

minio_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (minioweb)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  minio1_hostname=$(echo "${minio1_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/minioweb << 'END'
server {
  server_name $minio1_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:32772;
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

ln -s /etc/nginx/sites-available/minioweb /etc/nginx/sites-enabled
EOF

  sleep 2
}

minio2_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (minioapi)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  minio2_hostname=$(echo "${minio2_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/minioapi << 'END'
server {
  server_name $minio2_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:32771;
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

ln -s /etc/nginx/sites-available/minioapi /etc/nginx/sites-enabled
EOF

  sleep 2
}

type1_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (typebotviewer)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  type1_hostname=$(echo "${type1_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/typebotviewer << 'END'
server {
  server_name $type1_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:8080;
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

ln -s /etc/nginx/sites-available/typebotviewer /etc/nginx/sites-enabled
EOF

  sleep 2
}

type2_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (typebotbuilder)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  type2_hostname=$(echo "${type2_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/typebotbuilder << 'END'
server {
  server_name $type2_hostname;
  
  location / {
    proxy_pass http://127.0.0.1:8081;
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

ln -s /etc/nginx/sites-available/typebotbuilder /etc/nginx/sites-enabled
EOF

  sleep 2
}

system_certbot_typebot_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  type1_domain=$(echo "${type1_url/https:\/\/}")
  type2_domain=$(echo "${type2_url/https:\/\/}")
  minio1_domain=$(echo "${minio1_url/https:\/\/}")
  minio2_domain=$(echo "${minio2_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $type1_domain,$type2_domain,$minio1_domain,$minio2_domain
EOF

  sleep 2
}

system_success_type() {

  print_banner
  printf "${GREEN} 💻 Instalação concluída...${NC}"
  printf "${CYAN_LIGHT}";
  printf "\n\n"
  printf "\n"
  printf "Usuário minio: minio"
  printf "\n"
  printf "Senha: minio123"
  printf "\n"
  printf "URL front minio: https://$minio1_url"
  printf "\n"
  printf "URL back minio: https://$minio2_url"
  printf "\n"
  printf "URL TypeBot: https://$type1_url"
  printf "\n"
  printf "URL TypeBot back: https://$type2_url"
  printf "\n"
  printf "\n"
  printf "${GREEN} 💻 Caso não funcionar talvez teve algum erro durante instalação deve ser corrigido manualmente pelo ponteiner dados...${NC}"
  printf "${NC}";

  sleep 2
}