
class SendNotificationAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def post_create
    notifier.compose_text_mail('foo@example.com', 'テスト', '本文')
    notifier.push_notification('テスト通知')
  end

  def next_tick(tick)
    return if @send

    notifier.compose_text_mail('foo@example.com', 'テスト2', '本文')
    notifier.push_notification('テスト通知2')
    @send = true
  end

  def execute_action(action)
    if (action == 'mail')
      notifier.compose_text_mail('foo@example.com', 'テスト2', '本文')
    else
      notifier.push_notification(action, [
        { 'label' => '通知を送る',   'action' => 'push-aaa' },
        { 'label' => '通知を送る2',  'action' => 'push-bbb' },
        { 'label' => 'メールを送る', 'action' => 'mail' }
      ])
    end
    'OK'
  end

end

class ErrorAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def post_create
  end

  def next_tick(tick)
    fail 'test.'
  end

end

class ErrorOnCreateAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def initialize
    fail 'test.'
  end

  def post_create
  end

  def next_tick(tick)
  end

end

class ErrorOnPostCreateAgent

  extend Jiji::Model::Agents::Context
  include Jiji::Model::Agents::Agent

  def self.description
    'sample agent'
  end

  def self.property_infos
    []
  end

  def post_create
    fail 'test.'
  end

  def next_tick(tick)
  end

end
