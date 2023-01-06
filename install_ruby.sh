#!/bin/bash

# Прерывать скрипт при ошибке
set -e

# Прерывать если не передана переменная
set -u

# Показывать команды
set -x

echo 'Обновляем APT и устанавливаем Ruby и Bundler...'
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

echo 'Готово'
