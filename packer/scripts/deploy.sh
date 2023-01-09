#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Обновить apt, предварительно убедившись что systemd не запустил свои задачи...'
flock /var/lib/apt/daily_lock apt-get update
flock /var/lib/apt/daily_lock apt-get install -y git

mkdir --parents /var/www/
cd /var/www/

echo 'Копируем код приложения...'
git clone -b monolith https://github.com/express42/reddit.git

echo 'Переходим в директорию проекта и устанавливаем зависимости приложения...'
cd reddit && bundle install

echo 'Добавить unit для systemd...'
# https://unix.stackexchange.com/a/77278
# https://github.com/puma/puma/blob/master/docs/systemd.md#service-configuration
tee -a /etc/systemd/system/puma.service > /dev/null <<EOT
[Unit]
Description=Puma HTTP Server
After=network.target

# Uncomment for socket activation (see below)
# Requires=puma.socket

[Service]
# Puma supports systemd's 'Type=notify' and watchdog service
# monitoring, as of Puma 5.1 or later.
# On earlier versions of Puma or JRuby, change this to 'Type=simple' and remove
# the 'WatchdogSec' line.
Type=notify

# If your Puma process locks up, systemd's watchdog will restart it within seconds.
WatchdogSec=10

# Preferably configure a non-privileged user
# User=

# The path to your application code root directory.
# Also replace the "<YOUR_APP_PATH>" placeholders below with this path.
# Example /home/username/myapp
WorkingDirectory=/var/www/reddit

# Helpful for debugging socket activation, etc.
# Environment=PUMA_DEBUG=1

# SystemD will not run puma even if it is in your path. You must specify
# an absolute URL to puma. For example /usr/local/bin/puma
# Alternatively, create a binstub with 'bundle binstubs puma --path ./sbin' in the WorkingDirectory
#ExecStart=/<FULLPATH>/bin/puma -C <YOUR_APP_PATH>/puma.rb
ExecStart=/usr/local/bin/puma

# Variant: Rails start.
# ExecStart=/<FULLPATH>/bin/puma -C <YOUR_APP_PATH>/config/puma.rb ../config.ru

# Variant: Use 'bundle exec --keep-file-descriptors puma' instead of binstub
# Variant: Specify directives inline.
# ExecStart=/<FULLPATH>/puma -b tcp://0.0.0.0:9292 -b ssl://0.0.0.0:9293?key=key.pem&cert=cert.pem


Restart=always

[Install]
WantedBy=multi-user.target
EOT

echo 'Включить сервер...'
systemctl enable puma

echo 'Готово'
