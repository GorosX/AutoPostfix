#!/bin/bash

read -p "Indroduce el dominio: " DOMINIO
read -p "Introduce el hostname: " HOSTNAME

# Comprobar sí el usuario es root

if [ "$(id -u)" -ne 0 ]; then
        echo "Este scripts debe ejecutarse como root." >&2
        exit 1
fi

# Actualizar repositorios y paquetes

echo "Actualizando repositorios y paquetes..."

apt update && apt upgrade -y

# Instalar Postfix

echo "Instalando Postfix..."

DEBIAN_FRONTEND=noninteractive apt install -y postfix

# Configuración de Postfix

echo "Configurando Postfix..."

sudo postconf -e "myhostname = $HOSTNAME"
sudo postconf -e "mydomain = $DOMINIO"
sudo postconf -e "myorigin = /etc/mailname"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "mydestination = $HOSTNAME, localhost.$DOMINIO, localhost"
sudo postconf -e "relayhost = "
sudo postconf -e "mynetworks = 127.0.0.0/8"
sudo postconf -e "mailbox_size_limit = 0"
sudo postconf -e "recipient_delimiter = +"
sudo postconf -e "inet_protocols = ipv4"

# Configurar el nombre del dominio en mailname

echo "$DOMINIO" > /etc/mailname

# Reiniciar Postfix para aplicar la configuración

echo "Reiniciando Postfix..."

systemctl restart postfix

# Habilitar el servicio de Postfix en el arranque

echo "Habilitando el servicio de Postfix en el arranque..."

systemctl enable postfix

# Verificar el estado de Postfix

echo "Verificando el estado de Postfix..."

systemctl status postfix

echo "La instalación y configuración de Postfix se ha completado con éxito."

# Instalar Mailutils

echo "Instalando Mailutils..."

apt install -y mailutils

# Preguntar al usuario por la dirección de correo, CC y el asunto

read -p "Introduce la dirección de correo a la que quieres enviar el mensaje: " EMAIL
read -p "Introduce el asunto del mensaje: " ASUNTO
read -p "Introduce el contenido del mensaje: " MENSAJE
# Enviar el correo electrónico

echo $MENSAJE | mail -s "$ASUNTO" "$EMAIL"

echo "Se ha enviado un mensaje de confirmación a $EMAIL."
