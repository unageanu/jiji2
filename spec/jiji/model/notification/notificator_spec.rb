# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::Notificator do
  include_context 'use agent_setting'

  let(:push_notifier) do
    double('notifier')
  end
  let(:time_source) do
    container.lookup(:time_source)
  end
  let(:logger) do
    Logger.new STDOUT
  end
  let(:notificator) do
    mail_composer = container.lookup(:mail_composer)
    Jiji::Model::Notification::Notificator.new(backtests[0],
      agent_setting.id, push_notifier, mail_composer, time_source, logger)
  end
  let(:notification_repository) do
    container.lookup(:notification_repository)
  end

  after(:example) do
    Mail::TestMailer.deliveries.clear
  end

  it 'テキスト形式のメールを送信できる' do
    notificator.compose_text_mail('foo@example.com', 'テストメール', 'テスト')

    expect(Mail::TestMailer.deliveries.length).to eq 1
    mail = Mail::TestMailer.deliveries[0]
    expect(mail.subject).to eq 'テストメール'
    expect(mail.to).to eq ['foo@example.com']
    expect(mail.from).to eq ['jiji@unageanu.net']
    expect(mail.body.parts[0].content_type).to eq('text/plain; charset=UTF-8')
    expect(mail.body.parts[0].body.raw_source).to eq('テスト')

    notificator.compose_text_mail('foo@example.com',
      'テストメール2', 'テスト2', 'var@example.com')

    expect(Mail::TestMailer.deliveries.length).to eq 2
    mail = Mail::TestMailer.deliveries[1]
    expect(mail.subject).to eq 'テストメール2'
    expect(mail.to).to eq ['foo@example.com']
    expect(mail.from).to eq ['var@example.com']
    expect(mail.body.parts[0].content_type).to eq('text/plain; charset=UTF-8')
    expect(mail.body.parts[0].body.raw_source).to eq('テスト2')
  end

  it 'メールを送信できる' do
    notificator.compose_mail('foo@example.com', 'テストメール') do
      text_part do
        content_type 'text/plain; charset=UTF-8'
        body 'テスト'
      end
    end

    expect(Mail::TestMailer.deliveries.length).to eq 1
    mail = Mail::TestMailer.deliveries[0]
    expect(mail.subject).to eq 'テストメール'
    expect(mail.to).to eq ['foo@example.com']
    expect(mail.from).to eq ['jiji@unageanu.net']
    expect(mail.body.parts[0].content_type).to eq('text/plain; charset=UTF-8')
    expect(mail.body.parts[0].body.raw_source).to eq('テスト')
  end

  it 'push通知を送信できる' do
    expect(push_notifier).to receive(:notify).twice
    time_source.set(Time.at(100))

    notificator.push_notification('メッセージ', [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ])

    notifications = notification_repository.retrieve_notifications({
      backtest_id: backtests[0].id
    })
    expect(notifications.length).to be 1
    notification = notifications[0]
    expect(notification.backtest_id).to eq backtests[0].id
    expect(notification.agent.id).to eq agent_setting.id
    expect(notification.agent.name).to eq agent_setting.name
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'メッセージ'
    expect(notification.actions).to eq [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
    expect(notification.note).to eq nil
    expect(notification.options).to eq nil

    notificator.push_notification('メッセージ2', [
      { 'label' => 'あ', 'action' => 'aaa' }
    ], 'ノート', { chart: { pair: :EURJPY } })

    notifications = notification_repository.retrieve_notifications({
      backtest_id: backtests[0].id
    })
    expect(notifications.length).to be 2
    notification = notifications[1]
    expect(notification.backtest_id).to eq backtests[0].id
    expect(notification.agent.id).to eq agent_setting.id
    expect(notification.agent.name).to eq agent_setting.name
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'メッセージ2'
    expect(notification.actions).to eq [
      { 'label' => 'あ', 'action' => 'aaa' }
    ]
    expect(notification.note).to eq 'ノート'
    expect(notification.options).to eq({ 'chart' => { 'pair' => :EURJPY } })
  end
end
