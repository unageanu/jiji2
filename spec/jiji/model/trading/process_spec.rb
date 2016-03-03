# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Process do
  include_context 'use data_builder'
  let(:broker) { Jiji::Test::Mock::MockBroker.new }
  let(:context) { data_builder.new_trading_context(broker) }

  context 'thread poolを共有するprocessが1つの場合' do
    shared_examples 'process の基本操作ができる' do
      it 'start で処理を開始できる' do
        expects_process_waitting_for_start(@process)

        @process.start
        sleep 0.1

        expects_process_running(@process)
      end

      it 'cancel で処理を停止できる' do
        @process.start
        sleep 0.1

        @process.cancel

        expects_process_cancelled(@process)
      end

      it 'cancel した直後でも停止できる' do
        @process.start
        @process.cancel
        Thread.pass
        sleep 0.1 until @process.finished?

        expects_process_cancelled(@process)
      end

      it 'pause で処理を停止できる' do
        @process.start
        sleep 0.1

        @process.pause

        expects_process_paused(@process)
      end

      it 'pause した直後でも停止できる' do
        @process.start
        @process.pause
        Thread.pass
        sleep 0.1 until @process.finished?

        expects_process_paused(@process)
      end

      it 'メッセージを送信できる' do
        @process.start
        sleep 0.1

        q = []
        future = @process.post_exec do |context|
          q << context.status
          'x'
        end

        expect(future.value).to eq 'x'
        expect(q).to eq [:running]

        future = @process.post_exec do |_context|
          raise 'test'
        end

        expect { future.value }.to raise_error
      end
    end

    context 'fail_on_error=false の場合' do
      before(:example) do
        @process = Jiji::Model::Trading::Process.new(
          context, Thread.pool(1), false)
      end

      it_behaves_like 'process の基本操作ができる'

      it 'jobの処理でエラーになっても、処理は継続される' do
        @process.start
        sleep 0.1

        future = @process.post_exec do |_context|
          raise 'test'
        end
        expect { future.value }.to raise_error
        sleep 0.1

        expects_process_running(@process)

        # 次のjobも処理できる
        future = @process.post_exec { |_context| 'x' }
        expect(future.value).to eq 'x'
      end
    end

    context 'fail_on_error=true の場合' do
      before(:example) do
        @process = Jiji::Model::Trading::Process.new(
          context, Thread.pool(1), true)
      end

      it_behaves_like 'process の基本操作ができる'

      it 'jobの処理でエラーになると、以降の処理が停止する' do
        @process.start
        sleep 0.1

        future = @process.post_exec do |_context|
          raise 'test'
        end
        expect { future.value }.to raise_error
        sleep 0.1

        expects_process_failed_on_error(@process)
      end
    end
  end

  context 'thread poolを共有するprocessが複数ある場合' do
    before(:example) do
      @pool = Thread.pool(1)

      context1 = data_builder.new_trading_context(broker)
      context2 = data_builder.new_trading_context(broker)
      context3 = data_builder.new_trading_context(broker)

      @process1 = Jiji::Model::Trading::Process.new(
        context1, @pool, false)
      @process2 = Jiji::Model::Trading::Process.new(
        context2, @pool, true)
      @process3 = Jiji::Model::Trading::Process.new(
        context3, @pool, false)
    end

    it 'start で処理を開始できる' do
      processes = [@process1, @process2, @process3]

      processes.each do |p|
        expects_process_waitting_for_start(p)
      end

      @process1.start
      @process2.start

      sleep 0.1
      expects_process_running(@process1)
      expects_process_waitting_for_start(@process2)
      expects_process_waitting_for_start(@process3)

      # process1を停止 → 2が開始される
      @process1.cancel
      sleep 0.1

      expects_process_cancelled(@process1)
      expects_process_running(@process2)
      expects_process_waitting_for_start(@process3)

      @process3.start

      # process2をエラーで停止
      @process2.post_exec do |_context|
        raise 'test'
      end
      sleep 0.1

      expects_process_cancelled(@process1)
      expects_process_failed_on_error(@process2)
      expects_process_running(@process3)
    end

    it 'cancel で処理を停止できる' do
      processes = [@process1, @process2, @process3]

      processes.each(&:start)
      sleep 0.1
      expects_process_running(@process1)
      expects_process_waitting_for_start(@process2)
      expects_process_waitting_for_start(@process3)

      processes.each(&:cancel)
      sleep 0.1

      processes.each do |p|
        expects_process_cancelled(p)
      end
    end

    it 'pause で処理を一時停止できる / start で再開できる' do
      processes = [@process1, @process2, @process3]

      processes.each(&:start)
      sleep 0.1
      expects_process_running(@process1)
      expects_process_waitting_for_start(@process2)
      expects_process_waitting_for_start(@process3)

      # process1を一時停止 → 2が開始される
      @process1.pause
      sleep 0.1

      expects_process_paused(@process1)
      expects_process_running(@process2)
      expects_process_waitting_for_start(@process3)

      # process1を再開 → 2が実行中なので、まだ再開されない
      @process1.start
      sleep 0.1

      expects_process_waitting_for_start(@process1)
      expects_process_running(@process2)
      expects_process_waitting_for_start(@process3)

      # process2をキャンセル
      @process2.cancel
      sleep 0.1

      expects_process_waitting_for_start(@process1)
      expects_process_cancelled(@process2)
      expects_process_running(@process3)

      # process3をキャンセル
      @process3.pause
      sleep 0.1

      expects_process_running(@process1)
      expects_process_cancelled(@process2)
      expects_process_paused(@process3)
    end
  end

  def expects_process_waitting_for_start(process)
    expect(process.running?).to be false
    expect(process.finished?).to be false
    expect(process.alive_context?).to be false
    expect(get_context_status(process)).to be :wait_for_start
    expects_process_can_process_job(process)
  end

  def expects_process_running(process)
    expect(process.running?).to be true
    expect(process.finished?).to be false
    expect(process.alive_context?).to be true
    expect(get_context_status(process)).to be :running
    expects_process_can_process_job(process)
  end

  def expects_process_cancelled(process)
    expect(process.running?).to be false
    expect(process.finished?).to be true
    expect(process.alive_context?).to be false
    expect(get_context_status(process)).to be :cancelled
    expects_process_can_process_job(process)
  end

  def expects_process_paused(process)
    expect(process.running?).to be false
    expect(process.finished?).to be true
    expect(process.alive_context?).to be false
    expect(get_context_status(process)).to be :paused
    expects_process_can_process_job(process)
  end

  def expects_process_failed_on_error(process)
    expect(process.running?).to be(false)
    expect(process.finished?).to be(true)
    expect(process.alive_context?).to be(false)
    expect(get_context_status(process)).to be :error
    expects_process_can_process_job(process)
  end

  def get_context_status(process)
    process.post_exec { |c| c.status }.value
  end

  def expects_process_can_process_job(process)
    future = process.post_exec { |_context| 'x' }
    expect(future.value).to eq 'x'
  end
end
