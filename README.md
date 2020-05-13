# Criando Monitoramento de SSL no Zabbix

## Solução de monitoramento utilizando as ferramentas:

- ssl-cert-check - https://github.com/Matty9191/ssl-cert-check
- Zabbix Server 3.4.6 - https://www.zabbix.com/documentation/3.4/pt/manual

Vamos utilizar o recurso de checagem externa do zabbix **(External Check)** https://www.zabbix.com/documentation/3.4/pt/manual/config/items/itemtypes/external

A solução proposta checa a validade do certificado utilizando o script *ssl-cert-check* e a URL do host monitorado, existem outras utilidades bem úteis para o *ssl-cert-check*, dê uma olha na documentação que vale a pena.

Para utilizar os scripts externos, confirme o path dos scritps externos em seu servidor Zabbix:

`$ grep ExternalScripts /etc/zabbix/zabbix_server.conf`

Acesse o diretorio:  
`$ cd /usr/lib/zabbix/externalscripts`  

Baixe o script:  
`$ wget https://raw.githubusercontent.com/Matty9191/ssl-cert-check/master/ssl-cert-check`  

Ajuste as permissões:    
`$ chmod +x ssl-cert-check`  
`$ chown zabbix: ssl-cert-check`

Crie um shell script para usar no item do Zabbix:

`$ vim /usr/lib/zabbix/externalscripts/zabbix-check-ssl.sh `

```shell
#!/bin/bash
/usr/lib/zabbix/externalscripts/ssl-cert-check -s $1 -p 443 -n | cut -d "=" -f2
```

Ajuste as permissões:  
`$ chmod +x zabbix-check-ssl.sh`  
`$ chown zabbix: zabbix-check-ssl.sh`

Testando o script:
`$ bash zabbix-check-ssl.sh www.terra.com.br`

Resumindo, vamos chamar esse script pelo zabbix e passar o argumento do host para pegar quantos dias faltam para expirar o certificado.

Tudo funcionando, vamos para as configurações no Zabbix.

---
## Importando Template

Clone o repositório

`$ git clone https://github.com/terasaka/zabbix-monitoring.git`

Importe o template

> Configuration -> Templates 

![Import Template](https://github.com/terasaka/repo-img/raw/master/template-import.png)

Escolha o arquivo `TemplateSSL.xml`

![Import](https://github.com/terasaka/repo-img/raw/master/import.png)

Template importado

![Template](https://github.com/terasaka/repo-img/raw/master/template.png)

Basta associar os hosts que pretende monitorar e usar no hostname do host a URL monitorada.


## Criando Template e configurando o host monitorado

Caso queria criar o template manualmente e entender um pouco melhor, siga os passos abaixo:

> Configuration -> Templates

Após a criação, adicione um novo item:

> Items -> Create Item

![Create Item](https://github.com/terasaka/repo-img/raw/master/create-item.png)

Mantenha o intervalo de checagem em 30s somente durante os testes, após as configurações você pode manter em 24h ou no intervalo que desejar.

Crie o host e associe o templete no host que deseja monitorar.

![Host](https://github.com/terasaka/repo-img/raw/master/host.png)

![Host-Template](https://github.com/terasaka/repo-img/raw/master/host-template.png)

Após a criação do template, vamos validar se o item está coletando corretamente:

> Monitoring -> Latest data

Filtre o Host que você criou e expanda o item para verificar.

![Item](https://github.com/terasaka/repo-img/raw/master/item.png)

Pronto, já temos o item coletando corretamente, agora só falta criar as triggers para alarmar.

Nesse caso criremos duas trigger uma para 30 e outra para 60 dias.

Volte no template que foi criado e crie uma nova trigger:

> Configuration -> Templates -> {Template} -> Triggers -> Create Trigger

Trigger para 60 dias:

![Trigger-60](https://github.com/terasaka/repo-img/raw/master/trigger-60.png)

Trigger para 30 dias:

![Trigger-30](https://github.com/terasaka/repo-img/raw/master/trigger-30.png)

Dependencia para trigger de 30 dias:

![Trigger-60-Dependencies](https://github.com/terasaka/repo-img/raw/master/trigger-60-dependencies.png)

Triggers criadas:

![Triggers](https://github.com/terasaka/repo-img/raw/master/triggers.png)

Pronto, dessa forma quando algum certificado estiver com a data de validades abaixo de 60 dias será alarmado com a severidade Average e quando chegar em 30 dias a severidade será High.
