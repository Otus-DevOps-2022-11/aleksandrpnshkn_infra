#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Подождать пока systemd закончит автоматические обновления apt...'
flock /var/lib/apt/daily_lock

# Фикс ошибки с установкой из https-репозитория
# E: The method driver /usr/lib/apt/methods/https could not be found.
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates

echo 'Добавляем ключи и репозиторий MongoDB...'
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

echo 'Обновим индекс доступных пакетов и установим нужный пакет...'
sudo apt-get update
sudo apt-get install -y mongodb-org

echo 'Запускаем MongoDB...'
sudo systemctl start mongod
echo 'Добавляем в автозапуск...'
sudo systemctl enable mongod

echo 'Готово'
