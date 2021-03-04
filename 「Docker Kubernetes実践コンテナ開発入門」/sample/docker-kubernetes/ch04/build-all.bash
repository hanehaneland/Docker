#!/usr/bin/env bash

set -uex

echo "
# ディスク使用量などが原因で動作しない（コンテナが再起動を繰り返すなど）場合は一度ディスク容量に余裕をもたせる
docker system prune -a # すべての既存のDocker関連ファイル等を削除する。要注意。
docker volume rm $(docker volume ls -q)
"

##############################
# 初期化処理
##############################

[ -f docker-compose.yml ] && docker-compose down -v

##############################
# ch03で構築した環境を構築
##############################

cp ../ch03/ch03_5_1/docker-compose.yml .
docker-compose up -d

worker_job=$(docker container exec -it manager docker swarm init \
    | sed -ne 's/\(docker swarm join --token [^ ]*\).*/\1/gp')

sleep 60s

for workers in "worker01" "worker02" "worker03"
do
    docker container exec -it $workers $worker_job manager:2377
done

sleep 60s

##############################
# ch04全体の下準備
##############################

docker container exec -it manager docker network create --driver=overlay --attachable todoapp

sleep 30s

##############################
# ch04_2のtododb/tody_mysql
##############################

[ -d "tododb" ] || git clone "https://github.com/gihyodocker/tododb"

(
    cd tododb
    docker image build -t ch04/tododb:latest .
    docker image tag ch04/tododb:latest localhost:5000/ch04/tododb:latest
    docker image push localhost:5000/ch04/tododb:latest
)

# docker stack deploy向けのデータ作成

sleep 30s

cp -t ./stack/ ./ch04_2_6/todo-mysql.yml

docker container exec -it manager \
    docker stack deploy -c /stack/todo-mysql.yml todo_mysql

# データベースの初期化

sleep 100s

eval "$(docker container exec -it manager docker service ps todo_mysql_master --no-trunc --filter 'desired-state=running' --format 'docker container exec -it {{.Node}} docker container exec -it {{.Name}}.{{.ID}} init-data.sh' | tr -d '\r')"
# eval "$(docker container exec -it manager docker service ps todo_mysql_master --no-trunc --filter 'desired-state=running' --format 'docker container exec -it {{.Node}} docker container exec -it {{.Name}}.{{.ID}} mysql -u gihyo -pgihyo tododb' | tr -d  '\r')"

##############################
# ch04_3のtodoapiとch04_4のtodonginx/todo_app
##############################

[ -d "todoapi" ] || git clone "https://github.com/gihyodocker/todoapi"

(
    cd todoapi
    docker image build -t ch04/todoapi:latest .
    docker image tag ch04/todoapi:latest localhost:5000/ch04/todoapi:latest
    docker image push localhost:5000/ch04/todoapi:latest
)

[ -d "todonginx" ] || git clone "https://github.com/gihyodocker/todonginx"

(
    cd todonginx
    # not todonginx "nginx"
    docker image build -t ch04/nginx:latest .
    docker image tag ch04/nginx:latest localhost:5000/ch04/nginx:latest
    docker image push localhost:5000/ch04/nginx:latest
)


cp -t ./stack/ ./ch04_4_3/todo-app.yml

docker container exec -it manager \
    docker stack deploy -c /stack/todo-app.yml todo_app

sleep 100s

##############################
# ch04_5のtodoweb/todo_frontend
##############################


[ -d "todoweb" ] || git clone "https://github.com/gihyodocker/todoweb"

(
    cd todoweb
    docker image build -t ch04/todoweb:latest .
    docker image tag ch04/todoweb:latest localhost:5000/ch04/todoweb:latest
    docker image push localhost:5000/ch04/todoweb:latest
)


# 4.5.4のnginx-nuxt
# [ -d "todonginx" ] || git clone "https://github.com/gihyodocker/todonginx"

cp ./ch04_5_3/Dockerfile-nuxt ./todonginx/
cp ./ch04_5_3/nuxt.conf.tmpl ./todonginx/etc/nginx/conf.d/

(
    cd ./todonginx/
    docker image build -f Dockerfile-nuxt -t ch04/nginx-nuxt:latest .
    docker image tag ch04/nginx-nuxt:latest localhost:5000/ch04/nginx-nuxt:latest
    docker image push localhost:5000/ch04/nginx-nuxt:latest
)

cp -t ./stack/ ./ch04_5_4/todo-frontend.yml

docker container exec -it manager \
    docker stack deploy -c /stack/todo-frontend.yml todo_frontend

sleep 100s

##############################
# ch04_5のtodo_ingress
##############################

cp -t ./stack/ ./ch04_5_5/todo-ingress.yml

docker container exec -it manager \
    docker stack deploy -c /stack/todo-ingress.yml todo_ingress

sleep 100s

##############################
# 終了処理
##############################

echo "
# docker-compose stop && docker-compose rm
docker-compose down
# 関連ファイルを削除する
rm -rf tododb todoweb todonginx todoapi stack registry-data docker-compose.yml
"
