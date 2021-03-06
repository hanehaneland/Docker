Write-Host "
# ディスク使用量などが原因で動作しない（コンテナが再起動を繰り返すなど）場合は一度ディスク容量に余裕をもたせる
docker system prune -a
docker volume rm $(docker volume ls -q)
"

##############################
# 初期化処理
##############################

(Test-Path docker-compose.yml) -and (docker-compose down -v)

##############################
# ch03で構築した環境を構築
##############################

Copy-Item ../ch03/ch03_5_1/docker-compose.yml .
docker-compose up -d

Start-Sleep 20

$worker_job = docker container exec -it manager docker swarm init | Select-String "--token"

echo $worker_job

Start-Sleep 60

# manager:2377ではなく、docker-container exec -it manager docker swarm initで得られたものをそのまま使う。
@("worker01", "worker02", "worker03") | ForEach-Object{Invoke-Expression "docker container exec -it $_ $worker_job"}

Start-Sleep 60

##############################
# ch04全体の下準備
##############################

docker container exec -it manager docker network create --driver=overlay --attachable todoapp

Start-Sleep 30

##############################
# ch04_2のtododb/tody_mysql
##############################

(Test-Path "tododb") -or (git clone "https://github.com/gihyodocker/tododb")

cd tododb
docker image build -t ch04/tododb:latest .
docker image tag ch04/tododb:latest localhost:5000/ch04/tododb:latest
docker image push localhost:5000/ch04/tododb:latest
cd ..

# docker stack deploy向けのデータ作成

Start-Sleep 30

Copy-Item -Destination ./stack/ ./ch04_2_6/todo-mysql.yml

docker container exec -it manager `
    docker stack deploy -c /stack/todo-mysql.yml todo_mysql

# データベースの初期化

Start-Sleep 100

# tr -d '\r'が消えてるので要注意
$dbinit_job = docker container exec -it manager `
docker service ps todo_mysql_master --no-trunc --filter 'desired-state=running' --format 'docker container exec -it {{.Node}} docker container exec -it {{.Name}}.{{.ID}} init-data.sh'

echo "
db init!
$dbinit_job
"

Invoke-Expression $dbinit_job

Start-Sleep 30

##############################
# ch04_3のtodoapiとch04_4のtodonginx/todo_app
##############################

(Test-Path "todoapi") -or (git clone "https://github.com/gihyodocker/todoapi")

cd todoapi
docker image build -t ch04/todoapi:latest .
docker image tag ch04/todoapi:latest localhost:5000/ch04/todoapi:latest
docker image push localhost:5000/ch04/todoapi:latest
cd ..

(Test-Path "todonginx") -or (git clone "https://github.com/gihyodocker/todonginx")

cd todonginx
# not todonginx "nginx"
docker image build -t ch04/nginx:latest .
docker image tag ch04/nginx:latest localhost:5000/ch04/nginx:latest
docker image push localhost:5000/ch04/nginx:latest
cd ..

Copy-Item -Destination ./stack/ ./ch04_4_3/todo-app.yml

docker container exec -it manager `
    docker stack deploy -c /stack/todo-app.yml todo_app

Start-Sleep 100

##############################
# ch04_5のtodoweb/todo_frontend
##############################


(Test-Path "todoweb") -or (git clone "https://github.com/gihyodocker/todoweb")

cd todoweb
docker image build -t ch04/todoweb:latest .
docker image tag ch04/todoweb:latest localhost:5000/ch04/todoweb:latest
docker image push localhost:5000/ch04/todoweb:latest
cd ..

# 4.5.4のnginx-nuxt

Copy-Item ./ch04_5_3/Dockerfile-nuxt ./todonginx/
Copy-Item ./ch04_5_3/nuxt.conf.tmpl ./todonginx/etc/nginx/conf.d/

cd ./todonginx/
docker image build -f Dockerfile-nuxt -t ch04/nginx-nuxt:latest .
docker image tag ch04/nginx-nuxt:latest localhost:5000/ch04/nginx-nuxt:latest
docker image push localhost:5000/ch04/nginx-nuxt:latest
cd ..

Copy-Item -Destination ./stack/ ./ch04_5_4/todo-frontend.yml

docker container exec -it manager `
    docker stack deploy -c /stack/todo-frontend.yml todo_frontend

Start-Sleep 100

##############################
# ch04_5のtodo_ingress
##############################

Copy-Item -Destination ./stack/ ./ch04_5_5/todo-ingress.yml

docker container exec -it manager `
    docker stack deploy -c /stack/todo-ingress.yml todo_ingress

Start-Sleep 100

##############################
# 終了処理
##############################

echo '
# docker-compose stop && docker-compose rm
docker-compose down
# 関連ファイルを削除する
@("tododb","todoweb","todonginx","todoapi","stack","registry-data","docker-compose.yml") | ForEach-Object{ Remove-Item -Recurse -Force $_ }
'
