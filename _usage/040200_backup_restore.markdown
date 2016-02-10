---
layout: usage
title:  "データのバックアップとリストア"
class_name: "backup_restore"
nav_class_name: "lv2"
---

Jijiのデータをバックアップ/リストアする手順を解説します。

エージェントのコードやバックテストの結果、通知、ログ、設定情報などすべてのデータは、 `MongoDB` に格納されています。
このデータをバックアップすれば、あとで環境を復元できます。

`MongoDB` 内のデータのうち、利用者のメールアドレス、およびSMTPサーバーのアカウント/パスワードは、暗号化して格納されています。
暗号化には環境ごとに生成される <code>SECRET KEY</code> を使用しており、環境が変わる(Dockerコンテナを作り直す等する)とデータを復号できなくなります。
このような場合には、<b>リストア後に設定画面から値を再設定する</b>必要がありますのでご注意ください。

<div class="notice no_indent">
※バックアップ/リストアには <code>mongodump</code> <code>mongorestore</code> など MongoDB Tools に含まれるコマンドが必要です。
ご利用の環境に合わせたものを、<a href="https://docs.mongodb.org/manual/installation/" target="_blank">こちらから</a>事前にインストールしておいてください。
</div>



<h2>Herokuにインストールしている場合</h2>

<b>前準備:</b>

[Heroku](https://www.heroku.com/home) にインストールした場合、クラウド型のMongoDBサービスの `MongoLab` を利用するように設定されています。
最初に、 `MongoLab` の管理画面にアクセスし、データベースのホスト名とデータベース名を取得します。
また、バックアップを実行するユーザーも作成します。

1. [Heroku](https://id.heroku.com/login) にログインして、 `Dashboard` からアプリを選択します。
![アプリを選択](/images/usage/backup_restore/backup_restore_01.png)

2. `Add-ons` の `MongoLab` をクリックします。
![MongoLabの管理画面へ](/images/usage/backup_restore/backup_restore_02.png)

3. `MongoLab` の管理画面が開くので、データベースのホスト名とデータベース名をメモしておきます。
![MongoLabの管理画面](/images/usage/backup_restore/backup_restore_03.png)

4. 次に `Users` タブを選択して、 `Add database user` からバックアップで使用するユーザーを作成します。
![バックアップ用ユーザーの作成](/images/usage/backup_restore/backup_restore_04.png)

以上で前準備は終わりです。

<br/>
<b>バックアップ:</b>
<p>以下を実行します。</p>

{% highlight sh %}
$ mongodump -h <データベースホスト名> -d <データベース名> -u <バックアップ用ユーザー名> -p <バックアップ用ユーザーのパスワード> -o <バックアップの保存先ディレクトリ>
{% endhighlight %}

バックアップの保存先ディレクトリの下にデータベース名でディレクトリが作成され、その中にバックアップデータが出力されます。リストア時には、データベース名のディレクトリを指定します。

<br/>
<b>リストア:</b>

<p>システムを一旦停止します。</p>

{% highlight sh %}
$ heroku ps:scale web=0 --app <Herokuのアプリ名>
{% endhighlight %}

<p><code>MongoLab</code>管理画面の<code>Collections</code>タブから、すべてのコレクションを削除します。</p>

<img class="indent" title="コレクションの削除" alt="コレクションの削除"
 src="/images/usage/backup_restore/backup_restore_05.png"
/>

<p>以下を実行してデータベースをリストアします。</p>

{% highlight sh %}
$ mongorestore --batchSize=100 -h <データベースホスト名> -d <データベース名> -u <バックアップ用ユーザー名> -p <バックアップ用ユーザーのパスワード> <バックアップの保存先ディレクトリ>
{% endhighlight %}

<p>システムを再起動します。</p>

{% highlight sh %}
$ heroku ps:scale web=1 --app <Herokuのアプリ名>
{% endhighlight %}

新しく構築した環境にデータを移した場合は、メールアドレスとSMTPサーバーの設定を再度行ってください。


<h2>Dockerにインストールしている場合</h2>

<b>バックアップ:</b>
<p>jiji_mongodb コンテナが動作している状態で、以下を実行します。</p>

{% highlight sh %}
$ mongodump  -d jiji --port <mongodbが動作しているポート:デフォルト27018> -o <バックアップの保存先ディレクトリ>
{% endhighlight %}

バックアップの保存先ディレクトリの下にデータベース名でディレクトリが作成され、その中にバックアップデータが出力されます。リストア時には、データベース名のディレクトリを指定します。

<br/>
<b>リストア:</b>

<p>システム全体を一旦停止し、<code>jiji_mongodb</code> コンテナだけを起動します。</p>

{% highlight sh %}
$ sudo docker-compose stop
$ sudo docker start jiji_mongodb
{% endhighlight %}

<p><code>jiji_mongodb</code> コンテナの <code>jiji</code> データベースを削除します。</p>

{% highlight sh %}
$ mongo --port <mongodbが動作しているポート:デフォルト27018>
> show dbs
jiji   0.203GB
local  0.078GB
> use jiji
switched to db jiji
> db.dropDatabase()
{ "dropped" : "jiji", "ok" : 1 }
> show dbs
local  0.078GB
> exit
{% endhighlight %}

<p>以下を実行してデータベースをリストアします。</p>

{% highlight sh %}
$ mongorestore -d jiji --batchSize=100 --port <mongodbが動作しているポート:デフォルト27018> <バックアップの保存先ディレクトリ>
{% endhighlight %}

<p>システムを再起動します。</p>

{% highlight sh %}
$ sudo docker-compose start
{% endhighlight %}

新しく構築した環境にデータを移した場合は、メールアドレスとSMTPサーバーの設定を再度行ってください。
