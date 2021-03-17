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

|設定値|説明|
|---|---|
|no|再起動しない|
|on-failure|終了ステータスが0でないときに再起動する|
|on-failure:回数n|終了ステータスが0でないときにn回再起動する|
|always|常に再起動する|
|unless-stopped|直近のコンテナが停止状態でなければ、常に再起動する|

### コンテナのネットワーク設定
`docker container run [ネットワークオプション] [イメージ名] [:タグ名] [引数]`

|オプション|説明|
|---|---|
|--add-host=[ホスト名:IPアドレス]|コンテナの/etc/hostsのホスト名とIPアドレスを定義する|
|--dns=[IPアドレス]|コンテナ用のDNSサーバのIPアドレス指定|
|--expose|指定したレンジのポート番号を割り当てる|
|--mac-address=[MACアドレス]|コンテナのMACアドレスを指定する|
|--net=[bridge ｜ none ｜ container:<name ｜ id> ｜ host ｜ NETWORK]※2|コンテナのネットワークを指定する|
|--hostname, -h|コンテナ自身のホストを指定する|
|--publish, -p[ホストのポート番号]:[コンテナのポート番号]|ホストとコンテナのポートマッピング|
|publish-all, -p|ホストの任意のポートをコンテナに割り当てる|

※2 --netオプションの指定

|設定値|説明|
|---|---|
|bridge|ブリッジ接続(デフォルト)を使う|
|none|ネットワークに接続しない|
|container:[name ｜ id|他のコンテナのネットワークを使う|
|host|コンテナがホストOSのネットワークを使う|
|NETWORK|ユーザ定義ネットワークを使う|

ユーザ定義ネットワークは、[`docker network create`](#docker-network-create-オプション-ネットワーク)で作成する。

### リソースを指定してコンテナを生成/実行
`docker container run [リソースオプション] [イメージ名] [:タグ名] [引数]`

|オプション|説明|
|---|---|
|--cpu-shares, -c|CPUの使用の配分(比率)|
|--memory, -m|使用するメモリを制限して実行する(単位はb,k,m,gのいすれか)|
|--volume=[ホストのディレクトリ]:[コンテナのディレクトリ], -v|ホストとコンテナのディレクトリを共有|

### コンテナを生成/起動する環境を指定
`docker container run [環境設定オプション] [イメージ名] [:タグ名] [引数]`

|オプション|説明|
|---|---|
|--env=[環境変数], -e|環境変数を設定する|
|--env-file=p[ファイル名]|環境変数をファイルから設定する|
|--read-only=[true｜false]|コンテナのファイルシステムを読み込み専用にする|
|--workdir=[パス], -w|コンテナの作業ディレクトリを指定する|
|-u, --user[ユーザ名]|ユーザ名またはUIDを指定する|

## docker container start [オプション] [コンテナ識別子]
コンテナ起動をするコマンド

停止中のコンテナを起動するときに使う。コンテナに割り当てられたコンテナ識別子を指定して、コンテナを起動する。

|オプション|説明|
|---|---|
|--attach, -a|標準出力/標準エラー出力を開く|
|--interactive, -i|コンテナの標準入力を開く|

複数のコンテナを一度に起動したいときは、`docker container start [オプション] [コンテナ識別子] [コンテナ識別子]`

コンテナを再起動するときは [`docker container restart`](#docker-container-restart-オプション-コンテナ識別子)

## docker container stop [オプション] [コンテナ識別子]
コンテナを停止するコマンド

起動しているコンテナを停止するときに使う。コンテナに割り当てられたコンテナ識別子を指定して、コンテナを停止する。

|オプション|説明|
|---|---|
|--time, -t|コンテナの停止時間を指定する(デフォルトは10秒)|

コンテナを削除するときは、コンテナを停止する必要がある。

## docker container rm [オプション] [コンテナ識別子]
コンテナを削除するコマンド

停止しているコンテナプロセスを削除することができる。

|オプション|説明|
|---|---|
|--force, -f|起動中のコンテナを強制的に削除する|
|--volimes, -v|割り当てたボリュームを削除する|

停止中の全コンテナを削除するには、`docker container prune`

## docker container ps
コンテナの状態を確認するためのコマンド

## docker container pause [コンテナ識別子]
一時停止を行う

## docker container unpause [コンテナ識別子]
中断コンテナの再開

## docker container ls [オプション]
コンテナの稼働状態を一覧で確認するコマンド

|オプション|説明|
|---|---|
|-all, -a|起動中/停止中も含めて全てのコンテナの表示|
|--filter, -f|表示するコンテナのフィルタリング|
|--format|表示するフォーマットを指定|
|--last, -n|最後に起動されてからn件のコンテナのみ表示|
|--latest, -l|最後に起動されたコンテナのみ表示|
|--no-trunc|情報を省略しないで全て表示する|
|--quiet, -q|コンテナIDのみ表示|
|--size, -s|ファイルサイズの表示|

## docker container stats [コンテナ識別子]
指定のコンテナの稼働状態を確認するコマンド

実行中のプロセスを確認するときは、`docker container top [コンテナ識別子]`

## docker container restart [オプション] [コンテナ識別子]

|オプション|説明|
|---|---|
|--time, -t|コンテナの停止時間を指定する(デフォルトは10秒)|

<br>

# Dockerコンテナのネットワーク
Dockerコンテナ同志が通信するとき、Dockerネットワークを介して行う。

## docker network ls [オプション]
Dockerネットワークの一覧を確認するコマンド

|オプション|説明|
|---|---|
|-f, --filter=[]※3|出力をフィルタする|
|--no-trunc|詳細を出力する|
|-q, --quiet|ネットワークIDのを表示する|

※3フィルタリングで利用できるキー
|値|説明|
|---|---|
|driver|ドライバーの設定|
|id|ネットワークID|
|label|ネットワークに設定されたラベル|
|name|ネットワーク名|
|scope|ネットワークのスコープ(swarm/giobal/local)|
|type|ネットワークのタイプ(ユーザ定義ネットワークcustom/定義済みネットワークbuiltin)|

## docker network create [オプション] ネットワーク
新しいネットワークを作成するコマンド

|オプション|説明|
|---|---|
|--driver, -d|ネットワークブリッジまたはオーバレイ(デフォルトはbridge)|
|--ip-range|コンテナに割り当てるIPアドレスのレンジを指定|
|--subnet|サブネットをCIDR形式で指定|
|--ipv6|IPv6ネットワークを有効にするかどうか(true/false)|
|-label|ネットワークに設定するラベル|

## docker network connect [オプション] [ネットワーク] [コンテナ]
DockerコンテナをDockerネットワークに接続するコマンド

|オプション|説明|
|---|---|
|--ip|IPv4アドレス|
|--ip6|IPv6アドレス|
|--alias|エイリアス名|
|--link|他のコンテナへのリンク|

ネットワークから接続するときは`docker network disconnect`を使う。

## docker network inspect [オプション] [ネットワーク]
ネットワークの詳細を確認するコマンド

## docker network rm [オプション] [ネットワーク]
Dockerネットワークを削除するコマンド

ネットワークを削除するには、接続中のすべてのコンテナとの接続をdocker network disconnectで切断する必要がある。

<br>

# 稼働しているDockerコンテナの操作

## docker container attach [コンテナ識別子]
稼働しているコンテナに接続するコマンド

接続したコンテナごと終了させるときは、Ctrl + Cを、コンテナからデタッチするときはCtrl + P, Ctrl + Qを入力する。

## docker container exec [オプション] [コンテナ識別子] [実行するコマンド] [引数]
稼働しているコンテナで新たにプロセスを実行するコマンド

Webサーバのようにバックグラウンドで実行しているコンテナにアクセスしたいとき、docker container attachコマンドで接続しても、シェルが動作していない場合は、コマンドを受け付けることができない。そのため、docker container execコマンドを使って任意のコマンドを実行する。

|オプション|説明|
|---|---|
|--detach|コマンドをバックグラウンドで実行する|
|--interactive, -i|コンテナの標準入力を開く|
|--tty, -t|tty(端末デバイス)を使う|
|--user, -u|ユーザ名を指定|

## docker container top
稼働しているコンテナで実行されているプロセスを確認するコマンド

## docker container port
稼働しているコンテナで実行しているプロセスが転送されているポートを確認するコマンド

## docker container rename
コンテナの名前を変更するコマンド
![image](https://user-images.githubusercontent.com/63034711/111508109-ab102580-878e-11eb-80be-b4c3d7e5fa26.png)

## docker container cp
コンテナ内のファイルをホストにコピーするコマンド
![image](https://user-images.githubusercontent.com/63034711/111508454-11954380-878f-11eb-809f-0d802d52a872.png)

↑訂正<br>
ホストの/tmp/etcにコピーするとき➡︎ホストの/tmp/にコピーするとき

## docker container diff [コンテナ識別子]
コンテナ内でなんらかの操作を行い、コンテナがイメージから生成されたときからの差分を確認するコマンド

<br>

# Dockerイメージの作成
Dockerコンテナは、Dockerイメージをもとに作成するが、逆にDockerコンテナをもとにして、Dockerイメージを作成することもできる。

## docker container commit [オプション] [コンテナ識別子] [イメージ名[:タグ名]]

|オプション|説明|
|---|---|
|--author, -a|作成者を指定する(例:ASA SHIHO＜shiho@asa.yokohama＞)|
|--message, -m|メッセージを指定する|
|--change, -c|コミット例のDockerfile命令を指定|
|--pausem, -p|コンテナを一時停止してコミットする|

## docker container seport [コンテナ識別子]
tarファイルの作成をするコマンド

Dockerでは、動作しているコンテナのディレクトリ/ファイル群をまとめてtarファイルを作成することができる。このtarファイルをもとにして、別のサーバでコンテナを稼働させることができる。

## docker image import [ファイルまたはURL] - [イメージ名[:タグ名]]
LinuxのOSイメージのディレクトリ/ファイル群からDockerイメージを作成することができる。

## docker image save [オプション] [保存ファイル名] [イメージ名]
Dockerイメージをtarファイルに保存できるコマンド

保存するファイル名の指定は、-oオプションを指定する。

## docker image load [オプション]
tarファイルからイメージを生成できるコマンド

読み込むファイルの指定は、-iオプションを指定する。

## docker system prune [オプション]
使用していないイメージ/コンテナ/ボリューム/ネットワークを一括で削除できるコマンド

|オプション|説明|
|---|---|
|--all, -a|使用していないリソースを全て削除する|
|--force, -f|強制的に削除する|

# 目次


