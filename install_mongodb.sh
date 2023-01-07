#!/bin/bash

# НЕ Прерывать скрипт при ошибке, потому что в Actions будет для тестов использоваться docker, в котором нет systemd
set +e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

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

# Кажется в тестах скрипт запускается в docker-контейнере, и systemd там нету :\
if [[ -e /usr/bin/systemctl ]]; then
    echo 'Запускаем MongoDB...'
    sudo systemctl start mongod
    echo 'Добавляем в автозапуск...'
    sudo systemctl enable mongod
else
    echo 'systemd не используется. Запустить через init.d...'

    wget https://raw.githubusercontent.com/mongodb/mongo/v4.2/debian/init.d
    mv init.d /etc/init.d/mongo.sh
    chmod 755 /etc/init.d/mongo.sh
    /etc/init.d/mongo.sh start
fi

echo 'Готово'
