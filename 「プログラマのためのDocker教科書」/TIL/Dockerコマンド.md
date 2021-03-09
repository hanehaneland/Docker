# Dockerイメージの操作
イメージの実態は、「Dockerでサーバ機能を動かすために必要なディレクトリ/ファイル群」のこと。具体的には、Linuxの動作に必要な/etcや/binなどのディレクトリ/ファイル群。

## docker image ls [オプション] [レポジトリ名]
イメージの一覧表示を行うコマンド

|オプション|説明|
|---|---|
|-all, -a|全てのイメージの表示|
|--digests|ダイジェストを表示する|
|--no-trunc|結果を全て表示する(イメージIDがフルの長さで表示される)|
|--quiet, -q|DockerイメージIDのみ表示|

## docker image inspect [オプション] [イメージ名]
イメージの詳細情報の確認をするコマンド

OS情報の取得をしたければ`--format="{{ .Os}}"`のオプション<br>
ContainerConfigのImageの値を取得したいときは`--format="{{ .ContainerConfig.Image }}"`のオプションをつければよい。

## docker image tag [イメージ名] [Docker Hubのユーザ名]/[イメージ名]:[タグ名]
イメージにタグをつけるコマンド

## docker search [オプション] [検索キーワード]
イメージの検索をできるコマンド

|オプション|説明|
|---|---|
|--no-trunc|結果を全て表示する(イメージIDがフルの長さで表示される)|
|--limit=n|n件の検索結果を表示する|
|--filter=stars=n|お気に入りの数(n以上)の指定|

## docker image rm [オプション] [イメージ名]
イメージの削除

|オプション|説明|
|---|---|
|--force, -f|イメージを強制的に削除|
|--no-prun|中間イメージを削除しない|

## docker image prune [オプション]
未使用のイメージの削除

|オプション|説明|
|---|---|
|--all, -a|すべて削除|
|--force, -f|イメージを強制的に削除|

※使用していないDockerイメージは無駄なディスク容量を使用するため、定期的に削除するとよい

## docker login [オプション] [サーバ]
Docker Hubへのログイン

|オプション|説明|
|---|---|
|--password, -p|パスワード|
|--username, -u|ユーザ名|

## docker image push [イメージ名] [:タグ名]
Docker Hubにイメージをアップロードするコマンド

あらかじめ、Docker Hubにログインしておく必要がある。

## docker logout [サーバ名]
Docker Hubからログアウト

<br>

# Dockerコンテナの操作

## Dockerコンテナのライフサイクル
![image](https://user-images.githubusercontent.com/63034711/110431896-bd84c200-80f1-11eb-9cc5-a9918947a3b1.png)

## docker container create
コンテナを生成するコマンド

イメージに含まれるLinuxのディレクトリ/ファイル群のスナップショットをとる。
スナップショットとは、ストレージ中に存在するファイルとディレクトリを特定のタイミングで取り出したもののことを言う。

docker container createコマンドは、コンテナを作成するだけで、コンテナの起動はしない。

## docker container run [オプション] [イメージ名] [:タグ名] [引数]
コンテナ生成/起動をするコマンド

イメージからコンテナを生成し、コンテナ上で任意のプロセスを起動する。

(ex)Linuxのプロセス管理と同様にNginxなどのサーバプロセスをバックグラウンドで常時実行したり、場合によっては強制終了したりすることも可能。ポート番号のネットワークも設定することで、外部からのコンテナのプロセスにアクセスできる。

|オプション|説明|
|---|---|
|--attach, -a|標準入力(STDIN)/標準出力(STDOUT)/標準エラー(STDERR)にアタッチする|
|--cidfile|コンテナIDをファイルに出力する|
|--detach, -d|コンテナを生成し、バックグラウンドで実行する|
|--interactive, -i|コンテナの標準入力を開く|
|--tty, -t|端末デバイスを使う|

### 対話的実行
`docker container run -it --name "[コンテナ名]" [イメージ名] [コンテナで実行するコマンド]`


### バックグラウンド実行
`docker container run -d [イメージ名] [:タグ名] [引数] `

|オプション|説明|
|---|---|
|--detach, -d|バックグラウンドで実行する|
|--user, -u|ユーザ名を指定|
|--restart=[no ｜ on-failure ｜ on-failure:回数n ｜ always ｜ unless-stopped]※1|コマンドの実行結果によって再起動を行うオプション|
|--rm|コマンドの実行完了後にコンテナを自動で削除|

※1 --restartオプション

|オプション|説明|
|---|---|
|no|再起動しない|
|on-failure|終了ステータスが0でないときに再起動する|
|on-failure:回数n|終了ステータスが0でないときにn回再起動する|
|always|常に再起動する|
|unless-stopped|直近のコンテナが停止状態でなければ、常に再起動する|

## docker container start
コンテナ起動をするコマンド

停止中のコンテナを起動するときに使う。コンテナに割り当てられたコンテナ識別子を指定して、コンテナを起動する。

コンテナを再起動するときは `docker container restart`

## docker container stop
コンテナを停止するコマンド

起動しているコンテナを停止するときに使う。コンテナに割り当てられたコンテナ識別子を指定して、コンテナを停止する。

コンテナを削除するときは、コンテナを停止する必要がある。

## docker container rm
コンテナを削除するコマンド

停止しているコンテナプロセスを削除することができる。

## docker container ps
コンテナの状態を確認するためのコマンド

## docker container pause
一時停止を行う