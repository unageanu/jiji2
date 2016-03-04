---
layout: usage
title:  "各種金融・経済データを取得する"
class_name: "getting_financial_and_economic_data"
nav_class_name: "lv2"
---

[Quandl](https://www.quandl.com/) で提供されている、各種金融・経済データを取得して利用できます。

## 取得できるデータの例

以下のようなデータを取得できます。 (これらはすべて無料で利用できます。) <br/>
他にもさまざまなデータが有償/無償で提供されているので、気になるデータがある場合は、[Quandl](https://www.quandl.com/) のサイトで検索してみてください。

### 各国通貨の実効為替レート

- 外国為替市場における諸通貨の相対的な実力を測るための指標。([Wikipedia](https://ja.wikipedia.org/wiki/%E7%82%BA%E6%9B%BF%E3%83%AC%E3%83%BC%E3%83%88#.E5.AE.9F.E8.B3.AA.E5.AE.9F.E5.8A.B9.E7.82.BA.E6.9B.BF.E3.83.AC.E3.83.BC.E3.83.88) より)
- [Bank for International Settlementsデータベース](https://www.quandl.com/data/BIS)で、各国ごとの実質実効為替レート/名目実効為替レートが取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>BIS/EERBR_RBJP</td>
   <td><a href='https://www.quandl.com/data/BIS/EERBR_RBJP-Effective-Exchange-Rate-Narrow-Indices-Real-CPI-Based-JP-Japan' target='_blank'>実質実効為替レート - 日本</a></td>
 </tr>
 <tr>
   <td>BIS/EERBN_NBJP</td>
   <td><a href='https://www.quandl.com/data/BIS/EERBN_NBJP-Effective-Exchange-Rate-Narrow-Indices-Nominal-JP-Japan' target='_blank'>名目実効為替レート - 日本</a></td>
 </tr>
 <tr>
   <td>BIS/EERBR_RBUS</td>
   <td><a href='https://www.quandl.com/data/BIS/EERBR_RBUS-Effective-Exchange-Rate-Narrow-Indices-Real-CPI-Based-US-United-States' target='_blank'>実質実効為替レート - 米国</a></td>
 </tr>
 <tr>
   <td>BIS/EERBN_NBUS</td>
   <td><a href='https://www.quandl.com/data/BIS/EERBN_NBUS-Effective-Exchange-Rate-Narrow-Indices-Nominal-US-United-States' target='_blank'>名目実効為替レート - 米国</a></td>
 </tr>
</table>


### 国際収支統計

- 国やそれに準ずる地域の対外(居住者と非居住者との間の)経済取引(財とサービスおよび所得の取引・対外資産・負債の増減に関する取引・移転取引)の統計。( [Wikipedia](https://ja.wikipedia.org/wiki/%E5%9B%BD%E9%9A%9B%E5%8F%8E%E6%94%AF%E7%B5%B1%E8%A8%88) より)
- [Bank of Japan データベース](https://www.quandl.com/data/BOJ) から各項目のデータが取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6JYNCB</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6JYNCB-Current-account-Net-balance' target='_blank'>経常収支</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6JYNCAN</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6JYNCAN-Capital-account-Net-balance' target='_blank'>資本移転等収支</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6JYNFB</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6JYNFB-Financial-account-Net-balance' target='_blank'>金融収支</a></td>
 </tr>
</table>


### 対内外直接投資

- 日本企業による海外の企業に対する直接投資を対外直接投資、海外の企業による日本企業に対する直接投資を対内直接投資という ( [Wikipedia](https://ja.wikipedia.org/wiki/%E7%9B%B4%E6%8E%A5%E6%8A%95%E8%B3%87) より)
- [Bank of Japan データベース](https://www.quandl.com/data/BOJ)から各項目のデータが取得できます。


<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6H2</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6H2-Direct-Investment-Assets-Total-Execution' target='_blank'>対外直接投資 - 実行</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6H1</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6H1-Direct-Investment-Assets-Total-Withdrawal' target='_blank'>対外直接投資 - 回収</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6H</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6H-Direct-Investment-Assets-Total-Net' target='_blank'>対外直接投資 - ネット</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6I1</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6I1-Direct-Investment-Liabilities-Total-Execution' target='_blank'>対内直接投資 - 実行</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6I2</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6I2-Direct-Investment-Liabilities-Total-Withdrawal' target='_blank'>対内直接投資 - 回収</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6I</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6I-Direct-Investment-Liabilities-Total-Net' target='_blank'>対内直接投資 - ネット</a></td>
 </tr>
</table>


### 対内外証券投資

- 外国の株式，公債，社債などの有価証券への投資額。
- [Bank of Japan データベース](https://www.quandl.com/data/BOJ)で、各項目のデータが取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>BOJ/BPBPPI6D1N5</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPPI6D1N5-Portfolio-Investment-Assets-Total-Net' target='_blank'>対外証券投資 - 合計</a></td>
 </tr>
 <tr>
   <td>BOJ/BPBPBP6JYNFL2</td>
   <td><a href='https://www.quandl.com/data/BOJ/BPBPBP6JYNFL2-Financial-account-Portfolio-investment-Net-Liabilities' target='_blank'>対内証券投資 - 合計</a></td>
 </tr>
</table>

### CFTC建玉明細

- [米国商品先物取引委員会（Commodity Futures TradingCommission:CFTC）](http://www.cftc.gov/index.htm)が公開しているIMM通貨先物の建玉明細。
- [CFTCデータベース](https://www.quandl.com/data/CFTC)から取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>CFTC/TIFF_CME_JY_ALL</td>
   <td><a href='https://www.quandl.com/data/CFTC/TIFF_CME_JY_ALL-Positions-in-the-Japanese-Yen-TIFF' target='_blank'>CFTC建玉明細 - USD/JPY</a></td>
 </tr>
 <tr>
   <td>CFTC/TIFF_CME_EC_ALL</td>
   <td><a href='https://www.quandl.com/data/CFTC/TIFF_CME_EC_ALL-Positions-in-the-Euro-Fx-TIFF' target='_blank'>CFTC建玉明細 - USD/EUR</a></td>
 </tr>
</table>


### OECD景気先行指数

- OECD(経済協力開発機構)が作成しているしている景気の先行きを示す指標。
- [OECDデータベース](https://www.quandl.com/data/OECD)から取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>OECD/MEI_CLI_LOLITOAA_JPN_M</td>
   <td><a href='https://www.quandl.com/data/OECD/MEI_CLI_LOLITOAA_JPN_M-Amplitude-Adjusted-Cli-Jap' target='_blank'>OECD景気先行指数 - 日本</a></td>
 </tr>
 <tr>
   <td>OECD/MEI_CLI_LOLITOAA_USA_M</td>
   <td><a href='https://www.quandl.com/data/OECD/MEI_CLI_LOLITOAA_USA_M-Amplitude-Adjusted-Cli-United-S' target='_blank'>OECD景気先行指数 - 米国</a></td>
 </tr>
 <tr>
   <td>OECD/MEI_CLI_LOLITOAA_EA19_M</td>
   <td><a href='https://www.quandl.com/data/OECD/MEI_CLI_LOLITOAA_EA19_M-Amplitude-Adjusted-Cli-Euro-Area-19-Countries
' target='_blank'>OECD景気先行指数 - ユーロエリア19ヵ国</a></td>
 </tr>
</table>


### 日経平均株価, JASDAQ平均

- [日経データベース](https://www.quandl.com/data/NIKKEI) から取得できます。
- 取得できるのは前日の日足までです。リアルタイムなデータではないのでご注意ください。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>NIKKEI/INDEX</td>
   <td><a href='https://www.quandl.com/data/NIKKEI/INDEX-Nikkei-Index' target='_blank'>日経平均株価</a></td>
 </tr>
 <tr>
   <td>NIKKEI/JASDAQ</td>
   <td><a href='https://www.quandl.com/data/NIKKEI/JASDAQ-Nikkei-JASDAQ-Stock-Average-Index' target='_blank'>JASDAQ平均</a></td>
 </tr>
</table>



### 日本の個別株データ

- [Tokyo Stock Exchangeデータベース](https://www.quandl.com/data/TSE/9984-Softbank-Group-Corp-9984) から取得できます。
- 各種ETFのレートも取得できます。

<table>
 <tr>
   <th>quandlコード</th>
   <th>名前</th>
 </tr>
 <tr>
   <td>TSE/7203</td>
   <td><a href='https://www.quandl.com/data/TSE/7203-Toyota-Motor-Corp-7203' target='_blank'>トヨタ自動車</a></td>
 </tr>
 <tr>
   <td>TSE/8411</td>
   <td><a href='https://www.quandl.com/data/TSE/8411-Mizuho-Financial-Group-Inc-8411' target='_blank'>みずほフィナンシャルグループ</a></td>
 </tr>
 <tr>
   <td>TSE/9984</td>
   <td><a href='https://www.quandl.com/data/TSE/9984-Softbank-Group-Corp-9984' target='_blank'>ソフトバンクグループ</a></td>
 </tr>
 <tr>
   <td>TSE/1343</td>
   <td><a href='https://www.quandl.com/data/TSE/9984-Softbank-Group-Corp-9984' target='_blank'>ＮＥＸＴ　ＦＵＮＤＳ　東証ＲＥＩＴ指数連動型上場投信</a></td>
 </tr>
</table>

## データの取得方法

[Quandlの公式Rubyクライアントライブラリ](https://github.com/quandl/quandl-ruby)を利用します。


### Quandlのアカウントを作る

利用の前に、[Quandl](https://www.quandl.com/)のアカウント作成をお勧めします。

- アカウントなしで利用することも可能ですが、API呼び出し回数の上限が少なめです。
- アカウントを作成し、APIキーを設定して利用することで、制限が大幅に緩和されます。
   - 制限の詳細は[こちら](https://www.quandl.com/docs/api#rate-limits)をご覧ください。
- アカウント作成は無料です。

1. [Quandl](https://www.quandl.com/) のサイトにアクセスし、右上の `SIGN UP` をクリックします。
   ![手順1](/images/usage/getting_financial_and_economic_data/quandl_01.png)

2. 必要事項を入力して、`SIGN UP FREE` をクリックします。(GitHubやGoogleのアカウントでログインすることも可能です。)
   ![手順2](/images/usage/getting_financial_and_economic_data/quandl_02.png)

3. ログインしたら、右上のメニューから `ACOUNT SETTINGS` をクリックします。
   ![手順3](/images/usage/getting_financial_and_economic_data/quandl_03.png)

4. 左のメニューの `API KEY` をクリックすると、`API KEY` と `APIバージョン`が取得できるので、メモしておきます。
   ![手順4](/images/usage/getting_financial_and_economic_data/quandl_04.png)

### データを取得する

以下のコードでデータを取得できます。

- `Dataset.get()` の引数で、取得したいデータのquandlコードを指定します。
- `data(options)` で、データを取得できます。オプションでパラメータを指定することもできます。
  - 指定可能なパラメータの詳細は、[こちら](https://www.quandl.com/docs/api#datasets)を参照ください。
  - バックテストでデータを取得する場合は、`end_date`を指定して、テスト時点のデータを取得して利用してください。

{% highlight ruby %}
# エージェントコードの先頭で、ライブラリの読み込みとAPIキー/APIバージョンの設定を行います。
require 'quandl'

Quandl::ApiConfig.api_key = '<APIキー>'
Quandl::ApiConfig.api_version = '<APIバージョン>'

...(略

# 最新のデータを取得
data = Quandl::Dataset.get('TSE/9984').data( params: {limit:1})
logger.info data.first # => {"date"=>Thu, 03 Mar 2016, "open"=>5700.0, "high"=>5872.0, "low"=>5677.0, "close"=>5859.0, "volume"=>9218500.0}

# 2016-3-1 時点のデータを取得
data = Quandl::Dataset.get('TSE/9984').data( params: {limit:1, end_date: '2016-03-01'})
logger.info data.first # => {"date"=>Tue, 01 Mar 2016, "open"=>5574.0, "high"=>5640.0, "low"=>5562.0, "close"=>5621.0, "volume"=>9706500.0}
{% endhighlight %}

<div class="warn">
※通信を伴うため、データ取得にはやや時間がかかります。<code>next_tick(tick)</code> などで毎回呼び出していると、バックテストの実行が完了しなくなるのでご注意ください。
データの更新頻度に合わせて、取得タイミングの調整やキャッシングを行ってください。
</div>



<div class="next">
  <a href="020500_graphing.html">次のページへ: グラフを描く</a>
</div>
