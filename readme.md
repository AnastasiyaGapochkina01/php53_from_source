### *Домашняя работа №3: Установка ПО в Linux*
###### Подготовка к работе
1) Перейдите в папку ```03_installing_software``` 
2) Скопируйте ```env.example``` в ```.env``` и измените USERNAME для этого:
    - выполните
        ```
        cp env.example .env
        nano .env
        ```
        и после знака "=" впишите свое имя (ник, фамилию) - это будет отличать ваш контейнер от чужих. Cохраните файл и выйдите из редактора (для этого используйте последовательность: ctrl+O, enter, ctrl+X)
3) Выполните 
    ```
    docker compose up -d --build
    export CONTAINER_NAME=$(docker compose ps | awk 'NR==2{print $1}')
    ```
4) Подключитесь к контейнеру выполнив:
    ```
    docker exec -it $CONTAINER_NAME /bin/bash
    ```
#### Выполнение (Часть 1)
###### Будем устанавливать php5.3 из исходников :)
1) После подключения к контейнеру перейдите в директорию ```/usr/src/php```
2) Выполните команды
    ```
    export gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
    export debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"
    ```
3) Запустите конифгуратор
    ```
    ./configure \
        --host="${gnuArch}" \
        --with-libdir="/lib/${debMultiarch}/" \
        --with-config-file-path="${PHP_INI_DIR}" \
        --with-config-file-scan-dir="${PHP_INI_DIR}/conf.d" \
        --disable-cgi \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --enable-fpm \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-mhash \
        --with-pdo-sqlite=/usr \
        --with-sqlite3=/usr \
        --with-curl=/usr/local \
        --with-openssl=/usr/local/ssl \
        --with-readline \
        --with-recode \
        --with-zlib
    ```
4) Выполните сборку
    ```
    make
    ```
    Она завалится с примерно такой ошибкой
    ```
    collect2: error: ld returned 1 exit status
    Makefile:260: recipe for target 'sapi/fpm/php-fpm' failed
    make: *** [sapi/fpm/php-fpm] Error 1
    ```
    При подготовке образа я специально пропустила одну из библиотек :) Вам нужно установить ```libcurl4-gnutls-dev``` с помощью ```apt```/```apt-get``` и снова запустить ```make```
5) Выполните
    ```
    make install
    ```
6) Выполните
    ```
    php -v
    ```
    должно вывести версию установленного php. Сохраните вывод в файл ```/home/$USERNAME/03_home_work``` (вместо $USERNAME подставьте имя пользователя, которое вы установили в .env)
#### Выполнение (Часть 2)
###### Будем устанавливать memstat из пакета
1) Установите утилиту ```wget``` с помощью ```apt```/```apt-get```
2) Скачайте .deb пакет
    ```
    wget http://ftp.de.debian.org/debian/pool/main/m/memstat/memstat_1.1+b1_amd64.deb
    ```
3) Установите пакет командой
    ```
    dpkg -i memstat_1.1+b1_amd64.deb
    ```
4) Выполните команду
    ```
    memstat
    ```
    Сохраните вывод в файл ```/home/$USERNAME/03_home_work``` (вместо $USERNAME подставьте имя пользователя, которое вы установили в .env)
#### Выполнение (Часть 3)
###### Будем устанавливать percona-mysql
1) Выполните
    ```
    apt install gnupg2
    ```
    Пакетный менеджер выругается, что не будут установлены зависимости. Чтобы починить, выполните
    ```
    apt-get -f install
    ```
    Теперь можно продолжить установку
    ```
    apt install gnupg2 lsb-release
    ```
2) Скачайте пакет:
    ```
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
    ```
3) Установите и обновите индекс:
    ```
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
    apt update
    ```
4) Установите percona-server
    ```
    apt install percona-server-server-5.7
    ```
5) Выполните
    ```
    mysql -V
    ```
    Сохраните вывод в файл ```/home/$USERNAME/03_home_work``` (вместо $USERNAME подставьте имя пользователя, которое вы установили в .env)
#### Выполнение (Часть 3)
###### Будем устанавливать lynx из исходников
1) Самостоятельно установите текстовый браузер lynx 
https://lynx.invisible-island.net/lynx2.9.0/index.html

#### Пример итогового файла 03_home_work
```
root@0df6105aab29:/usr/src/php# cat /home/anestesia/03_home_work
PHP version is:
PHP 5.3.29 (cli) (built: Jan 21 2024 07:20:41)
Copyright (c) 1997-2014 The PHP Group
Zend Engine v2.3.0, Copyright (c) 1998-2014 Zend Technologies
Memory statisctic in container:
    488k: PID     1 (/bin/bash)
    512k: PID     6 (/bin/bash)
    364k: PID 66865 (/usr/bin/memstat)
   1048k(    968k): /bin/bash 1 6 1 6 1 6
    156k(    132k): /lib/x86_64-linux-gnu/ld-2.19.so 1 6 66865 1 6 66865 1 6...
   7884k(   1668k): /lib/x86_64-linux-gnu/libc-2.19.so 1 6 66865 1 6 66865 1...
   4116k(     12k): /lib/x86_64-linux-gnu/libdl-2.19.so 1 6 1 6 1 6
   4248k(    144k): /lib/x86_64-linux-gnu/libncurses.so.5.9 1 6 1 6 1 6
   4188k(     84k): /lib/x86_64-linux-gnu/libnsl-2.19.so 1 6 1 6 1 6
   4132k(     28k): /lib/x86_64-linux-gnu/libnss_compat-2.19.so 1 6 1 6 1 6
   4148k(     44k): /lib/x86_64-linux-gnu/libnss_files-2.19.so 1 6 1 6 1 6
   4144k(     40k): /lib/x86_64-linux-gnu/libnss_nis-2.19.so 1 6 1 6 1 6
   4280k(    152k): /lib/x86_64-linux-gnu/libtinfo.so.5.9 1 6 1 6 1 6 1 6
     24k(      8k): /usr/bin/memstat 66865
--------
  39732k (   3280k)
Mysql version is:
mysql  Ver 14.14 Distrib 5.7.30-33, for debian-linux-gnu (x86_64) using  6.3
```
# ПОСЛЕ ОКОНЧАНИЯ РАБОТЫ НЕ ЗАБУДТЬЕ ВЫПОЛНИТЬ ```docker compose down```
