---
layout: usage
title:  "エージェントのカスタマイズ"
class_name: "customizing"
nav_class_name: "lv2"
---

規定のメソッドを実装することで、カスタマイズ可能なプロパティを追加したり、UIで表示される説明を変更したりできます。


<h3>プロパティの入力を受け付ける</h3>

エージェントにプロパティを追加するには、 `Agent#property_infos` をオーバーライドします。

- 戻り値として、プロパティの一覧情報(`Jiji::Model::Agents::Agent::Property`の配列)を返すようにします。
- `Agent#property_infos` は、クラスメソッドです。インスタンスメソッドではないのでご注意ください。

{% highlight ruby %}
# UIから設定可能なプロパティの一覧を返す。
def self.property_infos
  [
    # プロパティの識別子、表示名、初期値の順に指定します。
    Property.new('short', '短期移動平均線', 25),
    Property.new('long',  '長期移動平均線', 75)
  ]
end
{% endhighlight%}

UIで設定されたプロパティは、 エージェントの初期化時に `properties=(props)` メソッドでエージェントに設定されます。
詳しくは [エージェントの初期化と実行の流れ](./020100_initialization.html) を参照ください。


<h3>説明をカスタマイズする</h3>

`description`メソッドをオーバーライドすることでエージェントの説明を指定できます。
こちらもクラスメソッドなのでご注意ください。

{% highlight ruby %}
def self.description
  <<-STR
移動平均を使うエージェントです。
-ゴールデンクロスで買い&売り建て玉をコミット。
-デッドクロスで売り&買い建て玉をコミット。
- -1000でトレーリングストップ
    STR
end
{% endhighlight%}


<div class="next">
  <a href="020900_samples.html">次のページへ: エージェントのサンプル</a>
</div>
