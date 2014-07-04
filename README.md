topology
========
[![Build Status](http://img.shields.io/travis/trema/topology/develop.svg?style=flat)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/trema/topology.svg?style=flat)][codeclimate]
[![Dependency Status](http://img.shields.io/gemnasium/trema/topology.svg?style=flat)][gemnasium]
[![Gitter chat](https://badges.gitter.im/trema/topology.png)][gitter]

Trema + Ruby で LLDP を使ったネットワークトポロジ探索

[travis]: http://travis-ci.org/trema/topology
[codeclimate]: https://codeclimate.com/github/trema/topology
[gemnasium]: https://gemnasium.com/trema/topology
[gitter]: https://gitter.im/trema/topology

準備
----

前もって Trema のビルド環境セットアップし、次のコマンドを実行。

```shell
$ git clone https://github.com/trema/topology.git
$ cd topology
$ bundle install
```

これで Trema など必要なものをインストールできます。


遊ぶ
----

おなじみ `trema run` で実行すると、トポロジ情報がテキストで見えます。

スイッチ 3 台の三角形トポロジ:

```shell
$ trema run ./topology_controller.rb -c triangle.conf
```

スイッチ 10 台のフルメッシュ:

```shell
$ trema run ./topology_controller.rb -c fullmesh.conf
```

スイッチやポートを落としたり上げたりしてトポロジの変化を楽しむ:
(以下、別ターミナルで)

```shell
$ trema kill 0x1  # スイッチ 0x1 を落とす
$ trema up 0x1  # 落としたスイッチ 0x1 をふたたび起動
$ trema port_down --switch 0x1 --port 1  # スイッチ 0x1 のポート 1 を落とす
$ trema port_up --switch 0x1 --port 1  # 落としたポートを上げる
```

graphviz でトポロジ画像を出す:

```shell
$ trema run "./topology_controller.rb graphviz /tmp/topology.png" -c fullmesh.conf
```

LLDP の宛先 MAC アドレスを任意のやつに変える:

```shell
$ trema run "./topology_controller.rb --destination_mac 11:22:33:44:55:66" -c fullmesh.conf
```
