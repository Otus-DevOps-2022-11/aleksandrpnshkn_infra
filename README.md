# aleksandrpnshkn_infra
aleksandrpnshkn Infra repository

## Как попасть на внутренний сервер?
Нужно использовать [ProxyJump](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Proxies_and_Jump_Hosts#Jump_Hosts_--_Passing_Through_a_Gateway_or_Two), который в командной строке указывается через параметр `-J`:
```bash
ssh -J aleksandrkrzhn@158.160.38.94 aleksandrkrzhn@10.128.0.15
```

Также, можно добавить alias в клиентский `~/.ssh/config`:
```
Host someinternalhost
	HostName 10.128.0.15
	User aleksandrkrzhn
	ProxyJump aleksandrkrzhn@158.160.38.94
```

## bastion
```
bastion_IP = 158.160.38.94
someinternalhost_IP = 10.128.0.15
```

## reddit-app
### Создание инстанса
В корне репозитория:
```bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --preemptible \
  --metadata-from-file user-data=startup-script.cloud-init.yml
```

### Доступы
```
testapp_IP = 51.250.88.11
testapp_port = 9292
```

## packer
В задании для packer есть конфиги для базового и полного образа. Добавлен скрипт для создания ВМ.

В базовых образах устанавливаются зависимости. Есть старые скрипты для shell-provisioner'а. Сейчас используется ansible-provisioner.

Сперва нужно создать файл `packer/variables.json` заполнить переменные по примеру из `packer/variables.example.json`.
Затем создать образы:
```bash
cd packer

# Создать базовый образ reddit-base с зависимостями приложения
packer build -var-file=./variables.json ./ubuntu16.json

# Создать полный образ reddit-full с установленным и запущенным приложением
packer build -var-file=./variables.json ./immutable.json

# Вернуться в корень
cd ..

# Создать раздельные образы app и db (ИЗ КОРНЯ)
packer build -var-file=./packer/variables.json ./packer/app.json
packer build -var-file=./packer/variables.json ./packer/db.json
```

Перед созданием ВМ нужно указать путь к своему ssh-ключу в скрипте `config-scripts/create-reddit-vm.sh`.
Также в этом скрипте нужно указать свой `image-folder-id`, в котором хранятся созданные образы, в параметре `--create-boot-disk`.
Далее:
```bash
# Вернуться в корень репозитория
cd ..

# Создать прерываемую ВМ на базе образа reddit-full
./config-scripts/create-reddit-vm.sh
```

## terraform
В terraform создается `count` виртуалок, к которым есть доступ через балансировщик нагрузки.
В качестве backend для стейта используется yandex storage. Блокировка (lock) стейта не реализована.
```bash
# (Опционально) запустить terraform нужной версии, прокинув туда .ssh для связи с yandex cloud. Контейнер удалится сам после exit
docker run --entrypoint "/bin/sh" --rm -it --volume "${PWD}:/app" --volume "${HOME}/.ssh:/root/.ssh" --workdir /app/terraform hashicorp/terraform:0.12.31

# Создать бакет для хранения состояний
terraform init
terraform apply

# Достать токены из output и использовать их в переменных для доступа к созданному бакету в дальнейшей работе
export AWS_ACCESS_KEY_ID=`terraform output bucket_access_key`
export AWS_SECRET_ACCESS_KEY=`terraform output bucket_secret_key`

# Задеплоить приложение
cd prod
terraform init
terraform apply
```
Приложение доступно по адресу external_ip_address_app на порту 9292

## ansible
```bash
cd ansible

# Установить зависимости
pip install -r requirements.txt

# Проверить доступность серверов
ansible all -m ping

# dry-run "всё-в-одном" плейбука
ansible-playbook reddit_app_one_play.yml --limit app --tags app --check
ansible-playbook reddit_app_one_play.yml --limit db --tags db --check

# Выполнить произвольную команду на сервере
ansible app -m command -a 'ls -alh /home/ubuntu/reddit'

# Настроить app/db хосты и поднять приложение
ansible-playbook site.yml
```
### Динамический inventory
JSON для динамического инвентаря отличается от JSON для статического.
У статического инвентаря структура похожа на yml-файл, а [в динамическом другие требования](https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#tuning-the-external-inventory-script).

Динамический инвентарь генерируется python-скриптом.
Справку по аргументам можно получить через `./yc-inventory.py --help`.
В данный момент IP серверов захардкожены в переменной внутри скрипта.

## Как запустить проект
- Создать базовые образы в packer (см. README)
- Создать серверы в terraform (см. README)
- Скопировать IP из вывода terraform в `ansible/inventory.yml` и IP базы в переменную `db_host` в плейбуке `ansible/app.yml`.
- Донастроить сервера и задеплоить приложение с помощью:
```bash
cd ansible
ansible-playbook site.yml
```
