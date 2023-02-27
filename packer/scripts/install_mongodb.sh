#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Обновить apt, предварительно убедившись что systemd не запустил свои задачи...'
flock /var/lib/apt/daily_lock apt-get update

# Фикс ошибки с установкой из https-репозитория
# E: The method driver /usr/lib/apt/methods/https could not be found.
flock /var/lib/apt/daily_lock apt-get install -y apt-transport-https ca-certificates

echo 'Добавляем ключи и репозиторий MongoDB...'
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

echo 'Обновим индекс доступных пакетов и установим нужный пакет...'
flock /var/lib/apt/daily_lock apt-get update
flock /var/lib/apt/daily_lock apt-get install -y mongodb-org

# https://unix.stackexchange.com/a/77278
cat <<EOT > /etc/mongod.conf
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0

# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOT

echo 'Запускаем MongoDB...'
sudo systemctl start mongod
echo 'Добавляем в автозапуск...'
sudo systemctl enable mongod

echo 'Готово'
