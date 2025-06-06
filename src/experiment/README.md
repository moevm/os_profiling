### Instruction -- Step-by-Step Guide for Conducting the Experiment
1) Настраиваем ssh, как показано в [инструкции](/wiki/yocto_cache/ssh_connection.md)
2) Заполняем файл [конфигуарции](src/setup_servers/auto_conf/[example]_experiment.conf) по пути `.../src/experiment/auto_conf/experiment.conf`
   -  a) `cache_ip` `hash_ip` -- ip адреса ваших кэш и хэш серверов соответсвенно (это те, которые вы настроили на шаге 1)
   -  b) `cache_usr` `hash_usr` -- имена пользователей ваших кэш и хэш серверов (это те, которые вы настроили на шаге 1)
   -  с) `hash_port` -- порт, на котором будет размещен хэш сервер
   -  d) `cache_start_port` -- порт на кэш сервере, начиная с которого будеи размещено `cache_num_port`
   -  e) `cache_num_port` -- количество портов, на которых размещаются кэш сервера; соответственно заняты будут порты, начиная с {`cache_start_port`} и до {`cache_start_port` + `cache_num_port` - 1}.
   -  f) `step` -- шаг, с которым будет происходить итератор теста
   -  g) `max_servsers` -- верхняя граница тестового диапазона
3) В ходе проведения эксперимента в корне репозитория автоматически создаются файлы формата `test_n_m`, где n - количество кэш серверов, m - номер повторения. Таким образом если m=1, то это значит, что сборка осуществляется без кэша хэш сервера, а если m=2, то с кэшем хэш сервера.

### Как работает эксперимент
#### Хэш сервер
Все, что нужно для его работы находится в `.../src/experiment/hash_server_setuper`, в этой же папке есть README.md.
#### Кэш сервер
Для корректного проведения эксперимента необходимо на компьютере, на котором будет находиться кэш-сервер в директории `/home/user/Desktop/test` склонировать репозиторий проекта и (в директории `src`) выполнить последовательность команд:
```sh
python3 -m venv venv
source venv/bin/activate
cd ./experiment/cache_server_setuper/reqs && pip3 install -r requirements.txt
``` 
После чего нужно собрать проект с помощью команд скрипта `entrypoint.sh`, чтобы можно было использовать его кэш в эксперименте. Либо просто подменить все файлы кэша на свои по пути `.../src/yocto-build/assembly/build/sstate-cache`.
Точкой входа в работу с кэш-сервером - `.../src/experiment/cache_server_setuper/manipulate_cache.sh`.
#### Эксперимент 
Запуск эксперимента производится командой, находясь в директории `.../src/experiment/`:
```
./main.sh
```
### Функционал скрипта `./manipulate_cache.sh`:

1. получение информации о использовании, например:

```shell
./manipulate_cache.sh
```

2. запуск pipeline, который включает в себя создание и запуск контейнеров с sstate-cache

```shell
./manipulate_cache.sh start <port> <count_of_servers>
```

Поля `<port>` и `<count_of_servers>` являются необязательными, их значения по дефолту 9000 и 4 соответственно.

3. остановка и удаление контейнеров с sstate-cache

```shell
./manipulate_cache.sh kill
```
