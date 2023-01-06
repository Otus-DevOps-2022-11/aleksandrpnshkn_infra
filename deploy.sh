#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Копируем код приложения...'
git clone -b monolith https://github.com/express42/reddit.git

echo 'Переходим в директорию проекта и устанавливаем зависимости приложения...'
cd reddit && bundle install

echo 'Запускаем сервер приложения в папке проекта...'
puma -d

echo 'Готово'
