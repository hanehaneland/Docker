# docker image ls [オプション] [レポジトリ名]
イメージの一覧表示を行うコマンド

|オプション|説明|
|---|---|
|-all, -a|全てのイメージの表示|
|--digests|ダイジェストを表示する|
|--no-trunc|結果を全て表示する(イメージIDがフルの長さで表示される)|
|--quiet, -q|DockerイメージIDのみ表示|

# docker image inspect [オプション] [イメージ名]
イメージの詳細情報の確認をするコマンド

OS情報の取得をしたければ`--format="{{ .Os}}"`のオプション<br>
ContainerConfigのImageの値を取得したいときは`--format="{{ .ContainerConfig.Image }}"`のオプションをつければよい。

