# 1. Build Image

# 開発用言語Goのバージョン1,13をベースイメージとして作成し、「builder」という別名をつける。この別名は任意の名前。
FROM golang:1.13 AS builder 

# Install dependencies
# 開発に必要なパッケージをインストールする。
WORKDIR /go/src/github.com/asashiho/dockertext-greet
RUN go get -d -v github.com/urfave/cli

# Build modules
# ローカル環境にあるソースコードをコンテナ内にコピーする。
COPY main.go .
# そのソースコードをgo buildコマンドでビルドし、「greet」という名前の実行可能バイナリファイルを作成する。
RUN GOOS=linux go build -a -o greet .

# ------------------------------

# 2. Production Image

# プロダクション用のDockerイメージのベースイメージは「busybox」を使う。BusyBoxは、基本的なLinuxコマンド群を単一のファイルにまとめたもので、必要最小限のLinuxシェル環境を提供する場合に利用されている。
FROM busybox  
# 開発環境用のDockerイメージでビルドした「greet」という名前の実行可能バイナリファイルをプロダクション環境用のDockerイメージにコピーする。
WORKDIR /opt/greet/bin
# Deploy modules
# コピーするときに、--fromオプションとして「builder」という名前のイメージからコピーするということを宣言する。
COPY --from=builder /go/src/github.com/asashiho/dockertext-greet/ .
# コピーした実行可能バイナリファイルを起動する命令
ENTRYPOINT ["./greet"]
