# Курсовая работа
## План
- Менифестом terraform описать создание виртуальных хостов с возможностью задавать их количество в переменных,
- Собрать образы приложений crawler и ui,
- Написать ansible playbooks по автоматической установке docker на хосты,
- Написать docker stack по деплою сервисов rabbitmq, mongodb, crawler и ui в docker swarm,
- Развернуть Prometheus для сбора метрик c сервисов и хостов инфраструктуры,
- Развернуть стек ELK для сбора логов с сервисов,
- Развернуть GitLab и настроить pipline для разворачивания инфраструктуры под приложение и пересборки docker образов и деплою в docker swarm сервисов crawler и ui при обновления кодовой базы последних,
- Развернуть проксирующий nginx с ssl шифрованием, что бы спрятать за ним приложение, Prometheus и ELK
- Настроить registry для docker образов в GitLab, вновь собранные контейнеры отправлять туда,
- Максимально автоматизировать развертывание инфраструктуры.

### Terraform
- За основу взял версию Ubuntu 20.04
- Terraform манифест находится в каталоге ```terraform/```, манифест постоен на модульной системе и описывает два типа инстансов. Инстанс для нод кластера и инстанс для ноды мониторинга      
- Манифест после создания виртуальлных машин запускает основной ansible playbook

Файловая структура каталога terraform
```css
.
├── main.tf
├── modules
│   ├── monitoring
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── nodes
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
├── terraform.tfvars.example
└── variables.tf
```

### Ansible
Описан ролевой системой, содержит следующие роли:  
docker-install - установка Docker Engine и всех необходимых зависимостей  
swarm-init     - инициализация Docker Swarm кластера  
workers-join   - добавление воркеров в кластер  
manager-add    - инициализация ноды мониторинга как второго менеджера  
node-label-db  - присвоение метки db одной из нод   
node-label-mon - присвоение метки mon ноде мониторинга  
network-add    - создание сети с overlay драйвером  
log-deploy     - деплой сервисов логирования в кластер  
app-deploy     - деплой микросервисного прилежения в кластер  
mon-deploy     - деплой сервислв мониторинга в кластер  
gitlab-runner-install - установка gitlab-runner на менеджерскую ноду  
user-group-add - добавление пользователя в группу   

Структура каталога
```css
├── ansible.cfg
├── dynamic-inventory.sh
├── playbooks
│   └── gitlab_install.yml
├── playbook.yml
├── roles
│   ├── app-deploy
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── docker-install
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── gitlab-runner-install
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   ├── log-deploy
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── manager-add
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── mon-deploy
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   ├── network-add
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── node-label-db
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── node-label-mon
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── swarm-init
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── user-group-add
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   └── workers-join
│       ├── defaults
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       └── vars
│           └── main.yml
├── terraform.tfstate
└── tokens
    ├── gitlab_token
    ├── gitlab_url
    ├── manager-address
    ├── manager-token
    └── worker-token
```

Для ansible реализован динамический инвентори, который отдает актуальную сформированную структуру хостов по именами, группами и ip адресами   
Пример выходных данных
```css
{
    "_meta": {
        "hostvars": {
            "monitoring": {
                "ansible_host": "51.250.13.180"
            },
            "node0": {
                "ansible_host": "51.250.0.167"
            },
            "node1": {
                "ansible_host": "51.250.74.34"
            },
            "node2": {
                "ansible_host": "51.250.80.139"
            }
        }
    },
    "all": {
        "children": [
            "manager",
            "other",
            "ungrouped",
            "workers"
        ]
    },
    "manager": {
        "hosts": [
            "node0"
        ]
    },
    "workers": {
        "hosts": [
            "monitoring",
            "node1",
            "node2"
        ]
    }
}
```

### Сборка docker образов приложений
- Образы crawler и ui собираются на основе python:3.9-alpine
- Docker файлы для сборки хранятся в ms/search_engine_crawler/ и ms/search_engine_ui/
- Собранные образы были отправлены в docker hub
- Для работы crawler_ui в requirements.txt была добавлена библиотека markupsafe

Структура каталога
```css
ms
├── search_engine_crawler
│   ├── crawler
│   │   ├── crawler.py
│   │   └── __init__.py
│   ├── Dockerfile
│   ├── __init__.py
│   ├── README.md
│   ├── requirements-test.txt
│   ├── requirements.txt
│   └── tests
│       └── test_crawler.py
└── search_engine_ui
    ├── Dockerfile
    ├── gunicornconf.py
    ├── README.md
    ├── requirements-test.txt
    ├── requirements.txt
    ├── tests
    │   └── test_ui.py
    └── ui
        ├── __init__.py
        ├── templates
        │   └── index.html
        └── ui.py
```

### Деплой приложения
Cистемой оркестрации выбран Docker Swarm, за ряд преимуществ перед k8s на маленьких проектах       
Создан docker-stack.yml, который описывает все сервисы приложения, количество реплик для приложений, метки и тип перезапуска

Структура каталога
```css
app
└── docker-stack.yml
```

### Мониторинг
Prometheus    - собирает метрики из приложений, содержит правила для мониторинга приложений в кластере и мониторинга самого кластера по CPU И RAM  
Alertmanager  - отправляет алерты в slack по триггерам  
cAdvisor      - собирает мертики из docker сервиса каждой ноды и записывает их в InfluxDB  
Node-exporter - собираем метрики с хостов  
Grafana       - визуализирует метрики из Prometheus и InfluxDB  

Структура каталога
```css
monitoring
├── alertmanager
│   ├── config.yml
│   └── config.yml.example
├── docker-stack.yml
└── prometheus
    ├── prometheus.yml
    └── rule
        ├── alert.rules
        ├── swarm_node.rules.yml
        └── swarm_task.rules.yml
```

### Логирование
Fluentd       - собирает логи в json из stdout приложений и отправляет их в Elasticsearch  
Elasticsearch - хранит в себе логи от fluentd  
Kibana        - визуализирует содержимое индекса fluentd-* опираясь на поле @timestamp для временного ряда    
Zippkin       - визуализирует трейсинг  

Структура каталога
```css
logging
├── docker-stack.yml
└── fluentd
    ├── Dockerfile
    └── fluent.conf
```


Пример вывода вышеуказанных сервисов задеплоенных в Swarm кластер
```css
ID             NAME                MODE         REPLICAS   IMAGE                             PORTS
dyuh6v9vpn1w   crawler_crawler     replicated   3/3        seeker00837149/crawler:latest     *:8000->8000/tcp
htool8ki72md   crawler_mongodb     replicated   1/1        mongo:latest                      *:27017->27017/tcp
4ucl6iqxiw02   crawler_rabbitmq    replicated   1/1        rabbitmq:3.9-management           *:5672->5672/tcp, *:15672->15672/tcp
8xbwl72sk21f   crawler_ui          replicated   2/2        seeker00837149/web_ui:latest      *:80->8000/tcp
ct1xqjytrxia   log_elasticsearch   replicated   1/1        elasticsearch:8.1.3               *:9200->9200/tcp, *:9300->9300/tcp
vuosk7dnzvgo   log_fluentd         replicated   2/2        seeker00837149/fluentd:latest     *:24224->24224/tcp, *:24224->24224/udp
vgx014qmu8nn   log_kibana          replicated   2/2        kibana:8.1.3                      *:5601->5601/tcp
0rs5jpwfdx93   log_zipkin          replicated   2/2        openzipkin/zipkin:2.21.0          *:9411->9411/tcp
k98apysjh4qk   mon_alertmanager    replicated   1/1        prom/alertmanager:latest          *:9093->9093/tcp
uz3ozog64lbb   mon_cadvisor        global       4/4        gcr.io/cadvisor/cadvisor:latest   *:8020->8080/tcp
okq9aky8zhn4   mon_grafana         replicated   1/1        grafana/grafana:7.5.4             *:3000->3000/tcp
4qpqjpbbba3a   mon_influx          replicated   1/1        influxdb:1.8-alpine
tjtggn836v8d   mon_node-exporter   global       4/4        prom/node-exporter:latest
zcnei285zuve   mon_prometheus      replicated   1/1        prom/prometheus:latest            *:9090->9090/tcp
```

### Запуск
Для запуска поднятия инфратсруктуры необходимо на Linux машине установить:
- Yandex Cloud
- Ansible
- Terraform
- подготовить ssh ключ для Ansible, путь вписать в ansible/ansible.cfg
- провисать в конфиг Terraform (terraform/terraform.tfvars) token, cloud_id, folder_id, zone, region, public_key_path, private_key_path, subnet_id, service_account_key_file
- склонировать репозиторий локлаьно
- из корня репозитория запустить скрипт ./start.sh


### CI/CD для приложения
Изначально развернул свой Gitlab сервер на нем и проводил тестирование, но обнаружил баг с работой gitlab-runner, перешел на облачный Gitlab, что бы сравнить работу раннера, в итоге на облачном Gitlab и остался с деплоем приложения.  
gitlab-ci.yml описывает пересборку образов crawler и ui, при коммите в репозиторий, с дальнейшей отправкой образов в GitHub.   Следующим этапом запускается деплой docker-stack.yml на менеджерской ноде Swarm кластера с принудительным перечиьыванием образов.

### ScreenCast
- Записал видео с развертыванием инфраструктуры, установке зависимостей и деплою сервисов по команде, показал результаты работы сервисов мониторинга и логирования, [ссылка на видео](https://disk.yandex.ru/i/JFBu-Ld4hYqGUw)  
- Забыл показать в первом видео, записал дополнительное, список сервисов в Swarm кластере, как реплики распределяются по нодам и работа динамического инвентори для ansible, [ссылка на видео](https://disk.yandex.ru/i/-NMBkQEDu5F8WA)
