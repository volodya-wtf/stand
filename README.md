# Деплой тестового стенда на ubuntu 20.04



#### docker-compose (*docker-compose.yml*)



**Используемые сервисы (*services*):**

| services          | image                                         | endpoint                     |
| ----------------- | --------------------------------------------- | ---------------------------- |
| httpd             | httpd:2.4                                     | https://localhost            |
| postgres          | postgres:14                                   |                              |
| pgadmin           | dpage/pgadmin4:latest                         | https://localhost/pgadmin/   |
| portainer         | portainer/portainer-ce:2.9.3                  | https://localhost/portainer/ |
| rstudio           | rocker/rstudio                                | https://localhost/rstudio/   |
| grafana           | grafana/grafana:latest                        | https://localhost/grafana/   |
| jupyter           | jupyter/base-notebook:latest                  | https://localhost/jupyter/   |
| nifi              | apache/nifi:latest                            | https://localhost/n1/        |
| keycloak          | jboss/keycloak:latest                         | https://localhost/auth/      |
| prometheus        | prom/prometheus:latest                        |                              |
| node-exporter     | prom/node-exporter:latest                     |                              |
| postgres-exporter | quay.io/prometheuscommunity/postgres-exporter |                              |
| cadvisor          | gcr.io/cadvisor/cadvisor:latest               |                              |



**Постоянные разделы (*persistant volumes*)**

-   postgres
-   pgadmin
-   portainer
-   research
-   nifi
-   grafana_data
-   prometheus_data



**IP-план (*IP plan*)**

| container_name    | ipv4_address | ports   |
| ----------------- | ------------ | ------- |
| httpd             | 172.18.0.2   | 443:443 |
| postgres          | 172.18.0.3   | :5432   |
| pgadmin           | 172.18.0.4   | :80     |
| portainer         | 172.18.0.5   | :9000   |
| rstudio           | 172.18.0.6   | :8787   |
| grafana           | 172.18.0.7   | :3000   |
| jupyter           | 172.18.0.8   | :8888   |
| nifi              | 172.18.0.9   | :8443   |
| keycloak          | 172.18.0.10  | :8080   |
| prometheus        | 172.18.0.11  | :9090   |
| node-exporter     | 172.18.0.12  | :9100   |
| postgres-exporter | 172.18.0.13  | :9187   |
| cadvisor          | 172.18.0.14  | :8080   |



​     

**Тома (volumes)**

| volumes                                                      | host                                 | container                                        |
| ------------------------------------------------------------ | ------------------------------------ | ------------------------------------------------ |
| \- ./httpd/cert:/usr/local/apache2/cert                      | ./httpd/cert                         | /usr/local/apache2/cert                           |
| \- ./httpd/httpd.conf:/usr/local/apache2/conf/httpd.conf     | ./httpd/httpd.conf                   | /usr/local/apache2/conf/httpd.conf               |
| \- /etc/localtime:/etc/localtime:ro                          | /etc/localtime:                      | /etc/localtime:ro                                |
| \- /var/run/docker.sock:/var/run/docker.sock:ro              | /var/run/docker.sock                 | /var/run/docker.sock:ro                          |
| \-./jupyter/jupyter_notebook_config.py:/home/jovyan/.jupyter/jupyter_notebook_config.py | ./jupyter/jupyter_notebook_config.py | /home/jovyan/.jupyter/jupyter_notebook_config.py |
| - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro | ./prometheus/prometheus.yml          | /etc/prometheus/prometheus.yml:ro                |
| - /proc:/host/proc:ro                                        | /proc /sys                           | /host/proc:ro /host/sys:ro                       |
| \- /sys:/host/sys:ro                                         | /sys                                 | /host/sys:ro                                     |
| - /:/rootfs:ro                                               | /                                    | /rootfs:ro                                       |
| \- /var/run:/var/run:rw                                      | /var/run                             | /var/run:rw                                      |
| \- /var/lib/docker:/var/lib/docker:ro                        | /var/lib/docker                      | /var/lib/docker:ro                               |



#### Этапы деплоя

Предварительно вам потребуется виртуальная машина с ubuntu-server:20.04, требования к машине:

- 50 Gb hdd
- 4 Gb RAM
- 4 CPU Core

Вам необходимо обновиться, установить любимый текстовый редактор и выполнить установку и настройку docker вот по этим ссылкам:

[ubuntu](https://docs.docker.com/engine/install/ubuntu/)

[linux-postinstall](https://docs.docker.com/engine/install/linux-postinstall/)	

Получение всех необходимых файлов для развертывания выполняется с использованием git. Вы клонируете репозиторий под пользователем deploy, у поьзователя deploy отсутствуют привелегии sudo и единственная его задача запускать Makefile. Установите утилиту make (переключившись на пользователя root, разумеется!), она нам понадобится:

```
apt-get install make

```

 

Теперь взглянем на структуру каталога с проектом:

![Каталог проекта](https://github.com/volodya-wtf/stand/blob/main/readme/dir.png)

Сдесь мы видим уже описанный выше *docker-compose.yml,* *Makefile с* командами запуска проекта, пример окружения *.env.example* и .gitignore. В папках распологаются файлы настроек для сервисов *grafana*, *httpd*, *jupyter*, *prometheus*. 

В файле docker-compose.yml вам необходимо изменить и раскомментировать для сервиса keycloak переменную окружения **KEYCLOAK_FRONTEND_URL**, задав ее равной *https://<IP адрес хоста или Доменное имя>/auth*

Файл с настройками Apache (httpd в docker-compose) лежат в файле ./httpd/httpd.conf Конфигурация Apache содержит такие важные составляющие, как: 

```bash
Listen 443 # Прослушиваемы порт
```



```bash
# Подключаемые модули
LoadModule proxy_html_module modules/mod_proxy_html.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
LoadModule session_module modules/mod_session.so
LoadModule session_cookie_module modules/mod_session_cookie.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule headers_module modules/mod_headers.so
```

Эндпоинты регистрируются так: создается VirtualHost на 443 порту, и он поделен на Location. Общими для всех Location будут две дерективы импорта ключей, расположенных в папке ./httpd/cert/ и созданных командой:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt
```

В файле настроек Apache необходимо изменить ServerName, задав равным вашему IP или доменному имени. Аналогично проделать для <Location /n1/>. 

Теперь мы готовы задать переменные окружения. Выполним в корне папки с проектом:

```bash
cp .env.example .env
```

Откройте полученный .env файл на редактирование, измените учетные данные для сервисов.

Теперь мы готовы выполнить install, находясь в корне проекта:

```bash
make install
```

Незамедлительно вы начнете видеть диагностические сообщения. В случае удачного завершения, список поднятых сервисов выглядит:

![docker_ps](https://github.com/volodya-wtf/stand/blob/main/readme/docker_ps.png)

#### Начнем поэтапный обход и диагностику сервисов.

1. httdp. Тут все тривиально.

![httpd](https://github.com/volodya-wtf/stand/blob/main/readme/httpd.png)

2. portainer. Свидетельством успешного старта будет список запущенных контейнеров.

   ![portainer](https://github.com/volodya-wtf/stand/blob/main/readme/portainer.png)

3.  Токен для jupyter

   

```bash
 docker logs jupyter -f
```

![](https://github.com/volodya-wtf/stand/blob/main/readme/jupyter.png)

Находим, копируем и вставляем 

[jupyter]: https://your-ip-or-domain/jupyter/	"Login"

![](https://github.com/volodya-wtf/stand/blob/main/readme/jupyter-1.png)

![ipython](https://github.com/volodya-wtf/stand/blob/main/readme/jupyter-2.png)

4. rstudio

Логинемся под учетными данными из .env

![rstudio](https://github.com/volodya-wtf/stand/blob/main/readme/rstudio.png)

5. keycloak

   Авторизация данными из .env 

   [keycloak]: https://your-ip-or-domain/auth/	"keycloak"

   ![keycloak](https://github.com/volodya-wtf/stand/blob/main/readme/keycloak.png)

Вид панели администратора keycloak

6. nifi 

Добавляем элемент и перемещаем. В случае проблем рекомендую проверить домен или ip адрес в конфиге Apache ./httpd/httpd.conf

![n1-1](https://github.com/volodya-wtf/stand/blob/main/readme/n1-1.png)

![n1-2](https://github.com/volodya-wtf/stand/blob/main/readme/n1-2.png))



7. postgres/pgadmin

   Логинимся и добавляем в интерфейсе сервер с postgres. Все данные для входа и добавления базы берем из .env

   ![pgadmin](https://github.com/volodya-wtf/stand/blob/main/readme/pgadmin.png)

8. Переходим к самому интересному, секции мониторинга

Логинимся данными из .env, создаем data source и импортируем три панели: *1860, 14114, 193*

![1](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-2.png)

![2](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-3.png)





![3](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-4.png)

И получаем соответственно:

![5](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-5.png)

Мониторинг docker:

![6](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-6.png)

Мониторинг postgres:

![7](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-7.png)

Мониторинг хоста:

![8](https://github.com/volodya-wtf/stand/blob/main/readme/grafana-8.png)



