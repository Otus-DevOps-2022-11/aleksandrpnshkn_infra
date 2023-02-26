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

Сперва нужно создать файл `packer/variables.json` заполнить переменные по примеру из `packer/variables.example.json`.
Затем создать образы:
```bash
cd packer

# Создать базовый образ reddit-base с зависимостями приложения
packer build -var-file=./variables.json ./ubuntu16.json

# Создать полный образ reddit-full с установленным и запущенным приложением
packer build -var-file=./variables.json ./immutable.json
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
БД и app разделены на разные виртуалки. БД доступна всем из интернета, это сделано для простоты соединения с сервером по ssh, в реальном окружении БД будет во внутренней сети.
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

#
```
