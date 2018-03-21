## kuro-beer's TODO
---
- [ ] 抽出〜加工〜学習〜cv〜予測まで簡単に試せるnotebook作る．
  - とりあえずlogistic回帰とかで．軽いやつ．

- [ ] インストール済xgboostがgpuに対応していなかった気がするので確認する．

- [ ] Downsampling方法を考える
  - click数が少ないipと多いipとの間にダウンロード率，app, channelあたりの偏りがないか見てみる．

- [ ] ipを集約したい．Embedding的な．
  - major app, major channelに対するClick頻度とかActiveな時間帯とかうまいこと使えないか検討．
  - なんかipの分布が…


- 前処理関連メモ
  - trainの2017-11-06 16:00:00より前のデータを捨てる
  - click_timeを分割する

##### archive
- [x] 生データそのままHDFに変換・保存


## 調べもの
---
- [ ] Web広告について．talkingdataについて
  - ここでtalkingdata社のサービスのデモで遊べる．ただしほぼ中国語( https://www.talkingdata.com/ )．わからん．

- [ ] channel id of mobile ad publisherとは．広告主？
- [ ] appはclickされたadが宣伝しているappのこと？

- [ ] 不均衡データ処理分類
  - [ ] to read: https://www.slideshare.net/sfchaos/ss-11307051

##### archive
- [x] AWSについて．分析が走りだしたら待ち時間とかに．
  - [x] 何ができるか
  - [x] どうやって使うか
  - とりあえず環境構築の手順は把握した．GPU系のインスタンスはもうひと手間かかりそう．
