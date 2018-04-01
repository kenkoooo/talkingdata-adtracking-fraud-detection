## kuro-beer's TODO
---
- appとchannelの間に従属関係はないらしい．ただし，クリック数上位のappは極端にchannel数が多い傾向にある．
  - app=クリック先のアプリ，channel=広告会社と仮定すると，広告を広く打つほどclickが多いと解釈できそう
  - app=広告を掲載しているアプリと仮定すると，広告がクリックされているアプリほどchannelが広い，となるので，channel=？？？
  - 個人的には前者推し．情報足りない感はあるけど．

---
- [ ] Downsampling方法を考える
  - click可能性のあるユーザーと可能性に乏しいユーザーで最初に絞れないか？
  - clickの連続性を見るならunique user単位で落としたほうが良かろうと思う

- [ ] ipを集約したい．Embedding的な．
  - major app, major channelに対するClick頻度とかActiveな時間帯とかうまいこと使えないか検討．

- [ ] クリックのSequenceから特徴量を作りたい
  - [ ] いくつかipを抜き出してきてクリック数の時系列推移を観察する
  - appとchannelを結合したやつをvocabularyにして，ipごと一連のクリックを文章に見立てたら自然言語処理的な解析ができそう．

- 前処理関連メモ
  - trainの2017-11-06 16:00:00より前のデータを捨てる
  - click_timeを分割する  
  - 用意したい変数一覧
    - [x] unique user id = ip*10^7 + os*10^4 + device (osは最大3桁, deviceは最大4桁)
    - [x] 現地時刻（UTC+8h） [以下すべて現地時刻ベース]
    - [x] date
    - [x] hour
    - [x] date-hour
    - [x] datetime(30min単位でrounding)
    - [x] datetime(15min単位でrounding)
    - [x] datetime(10min単位でrounding)
    - [x] datetime(5min単位でrounding)
    - [x] datetime(1min単位でrounding)
    - [x] uq userについて，直前のClickのapp, channel, 時間差
    - [x] uq userについて，直後のClickのapp, channel, 時間差
    - [ ] uq userについて，直前n分間ののClick回数
    - [ ] uq userについて，直後n分間のClick回数  

- 解析関係メモ
  - 試したいこと，試したこと
    - [ ] appとchannelを単一の変数にまとめて，各click前後

##### archive
- [x] Amazon RDSを立ち上げる
  - 立ち上げたt2.2xlarge , 500GB, postgreSQL

- [x] 生データそのままHDFに変換・保存
- なんかipの分布が…  
train
![train](https://github.com/kenkoooo/talkingdata-adtracking-fraud-detection/blob/master/kuro-beer/fig/hist_ip_train.png)  
test
![test](https://github.com/kenkoooo/talkingdata-adtracking-fraud-detection/blob/master/kuro-beer/fig/hist_ip_test.png)

## 調べもの
---
- [ ] 不均衡データ処理分類
  - [ ] to read: https://www.slideshare.net/sfchaos/ss-11307051

##### archive
- [x] channel id of mobile ad publisherとは．広告主？
- [x] appはclickされたadが宣伝しているappのこと？
  - app, channelに従属関係はなかった
  - click回数の多いappのうち，上位の数件はマルチチャネルの傾向が強く，click数中〜下位はシングル〜3チャネル程度
  - 情報足りない感あるけど，appはクリック先のアプリ，channelは広告会社をとりあえず想定

- [x] AWSについて．分析が走りだしたら待ち時間とかに．
  - [x] 何ができるか
  - [x] どうやって使うか
  - とりあえず環境構築の手順は把握した．GPU系のインスタンスはもうひと手間かかりそう．

  - [x] Web広告について．talkingdataについて
    - ここでtalkingdata社のサービスのデモで遊べる．ただしほぼ中国語( https://www.talkingdata.com/ )．わからん．

    - [x] Wordbatchについて
      - pipで入るようになってたのでとりあえず試した >> wordbatch_trial.ipynb
      - sklearn.feature_extraction.text.HashingVectorizerとかのwrapperだけど，sklearnと違ってマルチコア計算してくれる．
      - 文章を格納したベクトルを（最大単語数）\*（単語・n-gramごとのハッシュ値）の疎行列に変換してくれる．
      - 疎行列に入ってくる値は何？ここでのl2正則化ってなんぞ？
      - 他にもオンライン学習の機能があるらしいけどそのへんはよくわからん．
      - 個人的にはsklearnの方が安定してるっぽいしそっちを使いたい…．あまりに時間がかかるなら要検討
