## kuro-beer's TODO
---
- [ ] 抽出〜加工〜学習〜cv〜予測まで簡単に試せるnotebook作る．
  - とりあえずlogistic回帰とかで．軽いやつ．

- [ ] インストール済xgboostがgpuに対応していなかった気がするので確認する．

- [ ] Amazon RDSを立ち上げる

- [ ] Downsampling方法を考える
  - click数が少ないipと多いipとの間にダウンロード率，app, channelあたりの偏りがないか見てみる．

- [ ] ipを集約したい．Embedding的な．
  - major app, major channelに対するClick頻度とかActiveな時間帯とかうまいこと使えないか検討．

- [ ] クリックのSequenceから特徴量を作りたい
  - [ ] いくつかipを抜き出してきてクリック数の時系列推移を観察する
  - appとchannelを結合したやつをvocabularyにして，ipごと一連のクリックを文章に見立ててlistにまとめたら自然言語処理的な解析ができそう．

- 前処理関連メモ
  - trainの2017-11-06 16:00:00より前のデータを捨てる
  - click_timeを分割する  


##### archive
- [x] 生データそのままHDFに変換・保存
- なんかipの分布が…  
train
![train](https://github.com/kenkoooo/talkingdata-adtracking-fraud-detection/blob/master/kuro-beer/fig/hist_ip_train.png)  
test
![test](https://github.com/kenkoooo/talkingdata-adtracking-fraud-detection/blob/master/kuro-beer/fig/hist_ip_test.png)

## 調べもの
---
- [ ] channel id of mobile ad publisherとは．広告主？
- [ ] appはclickされたadが宣伝しているappのこと？

- [ ] Wordbatchについて
  - pipで入るようになってたのでとりあえず試した >> wordbatch_trial.ipynb
  - sklearn.feature_extraction.text.HashingVectorizerとかのwrapperだけど，sklearnと違ってマルチコア計算してくれる．
  - 文章を格納したベクトルを（最大単語数）\*（単語・n-gramごとのハッシュ値）の疎行列に変換してくれる．
  - [ ] 疎行列に入ってくる値は何？ここでのl2正則化ってなんぞ？
  - 他にもオンライン学習の機能があるらしいけどそのへんはよくわからん．
  - 個人的にはsklearnの方が安定してるっぽいしそっちを使いたい…．あまりに時間がかかるなら要検討

- [ ] 不均衡データ処理分類
  - [ ] to read: https://www.slideshare.net/sfchaos/ss-11307051

##### archive

- [x] AWSについて．分析が走りだしたら待ち時間とかに．
  - [x] 何ができるか
  - [x] どうやって使うか
  - とりあえず環境構築の手順は把握した．GPU系のインスタンスはもうひと手間かかりそう．

  - [x] Web広告について．talkingdataについて
    - ここでtalkingdata社のサービスのデモで遊べる．ただしほぼ中国語( https://www.talkingdata.com/ )．わからん．
