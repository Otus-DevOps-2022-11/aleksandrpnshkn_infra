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
```
testapp_IP = 51.250.2.254
testapp_port = 9292
```
