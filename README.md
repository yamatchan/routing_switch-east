# 動作環境

* PC × 3台  
  * サーバ … 1台  
　Mac Pro  
  * ホスト(A, B) … 2台  
　Mac Book Pro  
* スイッチ NEC製 PF5240  
datapath_idが0x11のVSIを作成し，31-33番ポートをマッピングしておく．

# 配線
サーバを31番ポート  
ホストAを32番ポート  
ホストBを33番ポート  
にそれぞれ接続する．


# イメージファイルの取得
所定のURLからイメージファイルをダウンロードする．  
zipファイルを解凍すると，以下のファイルが展開される．  

* Server.ova … サーバ
* HostA.ova … ホストA
* HostB.ova … ホストB


# イメージファイルの設定
* [File] -> [Inport Appliance…] より，  
ダウンロードしたイメージファイルをそれぞれの端末にインポートする．

## サーバの設定

* [Settings] -> [Network] より，ネットワークアダプタの設定を行う．  
  * Adapter 1  
Enable Network Adapter: Check  
Attached to: NAT  
Cable Connected: Check  
  * Adapter 2  
Enable Network Adapter: Check  
Attached to: Bridged Adapter  
Name: en*: Ethernet (スイッチに接続しているEtherポートを選択)  
Promiscuous Mode: Allow All  
Cable Connected: Check  
  * Adapter 3  
Enable Network Adapter: Check  
Attached to: Host-ponly Adapter  
Promiscuous Mode: Allow All  
Cable Connected: Check

## ホストA, Bの設定

* [Settings] -> [Network] より，ネットワークアダプタの設定を行う．
  * Adapter 1  
Enable Network Adapter: Check  
Attached to: NAT  
Cable Connected: Check  
  * Adapter 2  
Enable Network Adapter: Check  
Attached to: Bridged Adapter  
Name: en*: Ethernet (スイッチに接続しているEtherポートを選択)  
Promiscuous Mode: Allow All  
Cable Connected: Check

# 各端末を起動する
## サーバ
### Webサーバ・VM Managerを起動する
```
$ cd ~/ein_rails  
$ rails s -b 0.0.0.0
```

### Tremaを起動する
```
$ cd ~/routing_switch  
$ bin/trema run lib/routing_switch.rb
```

## ホストA, B
### OpenVZカーネルを起動する
[Shift]を押しながらホスト端末を起動する．  
すると，カーネル選択画面になるので，  
[Advanced options for Ubuntu] -> [Ubuntu, with Linux 2.6.32-openvz-042stab113.11-amd64]  
を選択する．  
OpenVZは自動起動設定されているので，起動するだけで準備は完了する．
