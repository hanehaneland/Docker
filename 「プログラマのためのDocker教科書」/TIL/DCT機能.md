# Docker Content Trust (DCT)
イメージの「なりすまし」や「改ざん」からイメージを保護する機能のこと

## Office Key
イメージ作成者がDockerレジストリにイメージをアップロード(docker image push)する前に、ローカル環境でイメージ作成者の署名をするために使う秘密鍵のこと

## DCTの有効化
$ `export DOCKER_CONTENT_TRUST=1`

DCTを有効にすると、イメージをダウンロードするときに以下のようにイメージの検証が行われる。

$` docker image pull ubuntu:latest`

![image](https://user-images.githubusercontent.com/63034711/109967539-e5aca380-7d34-11eb-84da-30f2a13ff037.png)


署名がついていないイメージを使おうとするとエラーになる。

## DCTの無効化
$ `export DOCKER_CONTENT_TRUST=0`
