---
layout: usage
title:  "Jijiを最新版にアップデートする"
class_name: "system_update"
nav_class_name: "lv2"
---

Jijiを最新版にアップデートする手順を解説します。

<h3>Herokuにインストールしている場合</h3>

※更新には、[Heroku Toolbelt](https://toolbelt.heroku.com/)が必要です。事前にインストールしておいてください。<br/>
※<b>1～4の手順は、初回のアップデートでのみ必要です。2回目以降は、5～6の手順だけ行えば更新できます。</b>

<p>1. まず初めにHerokuにログインします。Herokuのユーザー名、パスワードを入力してログインしてください。</p>
{% highlight sh %}
$ heroku login
{% endhighlight %}

<p>2.　次に、HerokuのGit Repositoryをローカルに複製します。</p>
{% highlight sh %}
$ heroku git:clone -a <デプロイ時に指定したアプリケーション名>
{% endhighlight %}

<p>3. 複製したリポジトリに移動し、GitHubのJijiリポジトリをリモートリポジトリとして追加します。</p>
{% highlight sh %}
$ cd <アプリケーション名>
$ git remote add jiji https://github.com/unageanu/jiji2.git
{% endhighlight %}

<p>4. 既存のコードを一旦削除します。</p>
{% highlight sh %}
$ git rm -rf .
{% endhighlight %}
<div class="notice" >
既存のコードは、GitHubのコードと紐ずいておらず、そのままマージするとコンフリクトが発生するため、一旦削除します。
</div>

<p>5. Jijiリポジトリの変更をローカルに適用します。</p>
{% highlight sh %}
$ git pull jiji master
{% endhighlight %}

<p>6. 変更をHerokuのリポジトリにPushします。</p>
{% highlight sh %}
$ git push heroku master
{% endhighlight %}

Herokuへのデプロイが成功すれば、更新は完了です。


<h3>dockerにインストールしている場合</h3>

<p>以下のコマンドを実行し、jiji_jiji コンテナに入ります。</p>

{% highlight sh %}
$ sudo docker exec -it jiji_jiji bash
{% endhighlight %}

<p>jiji_jijiコンテナ内で以下を実行し、システムのコードを最新のものに更新します。</p>

{% highlight sh %}
$ cd /app/jiji2
$ git pull origin master
$ bundle install
$ exit
{% endhighlight %}

<p>コードの更新が完了したら、起動中のコンテナを新しいDocker イメージとして保存。</p>

{% highlight sh %}
$ sudo docker commit jiji_jiji dockerjiji2_jiji:latest
{% endhighlight %}

<p>システムを再起動します。</p>

{% highlight sh %}
$ sudo /usr/local/bin/docker-compose stop
$ sudo /usr/local/bin/docker-compose up -d
{% endhighlight %}

以上で、更新は完了です。
