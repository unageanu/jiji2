# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Db::CreateCappedCollections do
  include_context 'use agent_setting'

  let(:script) do
    Jiji::Db::CreateCappedCollections.new({
      notifications: { size: 22_240, max: 3 },
      log_data:      { size: 400_000, max: 2 }
    })
  end
  let(:client) { Jiji::Db::SchemeStatus.mongo_client }

  before(:example) do
    drop_collections
  end

  after(:example) do
    drop_collections
  end

  it '#id' do
    expect(script.id).to eq 'v0to1/create_capped_collections'
  end

  it '#call' do
    script.call(nil, nil)

    expect(client[:notifications].capped?).to be true
    expect(client[:log_data].capped?).to be true

    check_notification_collection
    check_log_data_collection
  end

  def check_notification_collection
    5.times do |i|
      Jiji::Model::Notification::Notification.create(
        agent_setting, Time.at(i * 1000), nil, 'a' * 512).save!
    end
    expect(Jiji::Model::Notification::Notification.count).to eq 3
    timestamps = Jiji::Model::Notification::Notification
      .order_by(timestamp: :desc)
      .map { |n| n.timestamp.to_i }
    expect(timestamps).to eq([4 * 1000, 3 * 1000, 2 * 1000])
  end

  def check_log_data_collection
    time_source = Jiji::Utils::TimeSource.new
    log         = Jiji::Model::Logging::Log.new(time_source)
    logger      = Logger.new(log)

    44.times do |i|
      time_source.set(Time.at(i * 1000))
      logger.info('x' * 10_000)
    end

    expect(log.count).to eq 3
    timestamps = Array.new(log.count) { |i| log.get(i).timestamp.to_i }
    expect(timestamps).to eq([21_000, 32_000, 43_000])
  end

  def drop_collections
    client[:notifications].drop
    client[:log_data].drop
  end
end
