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
testapp_IP = 51.250.13.248
testapp_port = 9292
```
