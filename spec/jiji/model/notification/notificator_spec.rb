# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Notification::Notificator do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
  let(:backtest) do
    agent_registry      = container.lookup(:agent_registry)
    backtest_repository = container.lookup(:backtest_repository)
    agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    data_builder.register_backtest(1, backtest_repository)
  end
  let(:push_notifier) do
    double('notifier')
  end
  let(:time_source) do
    container.lookup(:time_source)
  end
  let(:notificator) do
    mail_composer = container.lookup(:mail_composer)
    Jiji::Model::Notification::Notificator.new(backtest.id,
      'agent_id', 'agent_name', push_notifier, mail_composer, time_source)
  end
  let(:notification_repository) do
    container.lookup(:notification_repository)
  end

  after(:example) do
    Mail::TestMailer.deliveries.clear
    data_builder.clean
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
    expect(push_notifier).to receive(:notify).once
    time_source.set(Time.at(100))

    notificator.push_notification('メッセージ', 'icon', [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ])

    notifications = notification_repository.retrieve_notifications({
      backtest_id: backtest.id
    })
    expect(notifications.length).to be 1
    notification = notifications[0]
    expect(notification.backtest_id).to eq backtest.id
    expect(notification.agent_id).to eq 'agent_id'
    expect(notification.agent_name).to eq 'agent_name'
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'メッセージ'
    expect(notification.icon).to eq 'icon'
    expect(notification.actions).to eq [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
  end
end
