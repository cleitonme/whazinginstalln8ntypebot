#!/bin/bash

get_renovar_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio com erro SSL:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " renovar_url
}

get_frontend_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio da interface web (Frontend):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio da sua API (Backend):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_n8n_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do N8N:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " n8n_url
}

get_wordpress_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do Wordpress:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " wordpress_url
}

get_portainer_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do Portainer:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " portainer_url
}

get_type1_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do TypeBot Front:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " type1_url
}

get_type2_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do TypeBot Back:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " type2_url
}

get_minio1_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do Minio:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " minio1_url
}

get_minio2_url() {
  print_banner
  printf "${WHITE} 💻 Digite o domínio do Minio API:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " minio2_url
}

get_email_end() {
  print_banner
  printf "${WHITE} 📧 Endereço de e-mail:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " email_end
}

get_senha_email() {
  print_banner
  printf "${WHITE} 🔑 Digite a Senha SMTP do Email (Se estiver usando gmail use a senha de app):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " senha_email
}

get_host_smtp() {
  print_banner
  printf "${WHITE} 📩 Digite o Host SMTP do Email (ex: smtp.gmail.com): ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " host_smtp
}

get_porta_email() {
  print_banner
  printf "${WHITE} 🚪 Digite a porta SMTP do Email (ex: 587):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " porta_email
}

get_smtp_secure() {
  print_banner
  printf "${WHITE} 🛡️ SMTP_SECURE (Se a porta SMTP for 465, digite true, caso contrario, digite false):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " smtp_secure
}

get_urls() {
  get_frontend_url
  get_backend_url
}

whazing_atualizar() {
  system_pm2_stop
  apagar_distsrc
  git_update
  backend_node_dependencies
  backend_node_build
  backend_db_migrate
  system_pm2_start
  frontend_node_dependencies
  frontend_node_build
}

ativar_firewall () {
  iniciar_firewall
}

desativar_firewall () {
  parar_firewall
}

Erro_global () {
  erro_banco
}

Install_n8n () {
  get_n8n_url
  postgresql_n8n
  stack_n8n
  n8n_caddy_setup
  system_caddy_restart
  system_success_n8n
}

Portainer_ssl () {
  get_portainer_url
  portainer_caddy_setup
  system_caddy_restart
  system_success_portainer
}

Install_typebot () {
  get_type1_url
  get_type2_url
  get_minio1_url
  get_minio2_url
  get_email_end
  get_senha_email
  get_host_smtp
  get_porta_email
  get_smtp_secure
  postgresql_typebot
  script_minio_typebot
  minio_typebot
  typebotviewer_typebot
  typebotbuilder_typebot
  minio_caddy_setup
  system_caddy_restart
  system_success_type
}

whazing_atualizar_beta() {
  system_pm2_stop
  apagar_distsrc
  update_beta
  backend_node_dependencies
  backend_node_build
  backend_db_migrate
  system_pm2_start
  frontend_node_dependencies
  frontend_node_build
}

inquiry_options() {

  print_banner
  printf "\n\n"
  printf "${WHITE} 💻 O que você precisa fazer?${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [1] Instalar N8N - necessario 1 dominio\n"
  printf "   [2] Instalar TypeBot - necessario 4 dominios\n"
  printf "   [3] Liberar acesso portainer dominio SSL - necessario 1 dominio\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
 
    1) 
      Install_n8n
      exit
      ;;

    2) 
      Install_typebot
      exit
      ;;
	  
    3) 
      Portainer_ssl
      exit
      ;;
	  

    *) exit ;;
  esac
}

