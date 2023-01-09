#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Обновить apt, предварительно убедившись что systemd не запустил свои задачи...'
flock /var/lib/apt/daily_lock apt-get update

echo 'Обновляем APT и устанавливаем Ruby и Bundler...'
flock /var/lib/apt/daily_lock apt-get install -y ruby-full ruby-bundler build-essential

echo 'Готово'
