# coding: utf-8

require 'jiji/test/test_configuration'

  
shared_examples "process の基本操作ができる" do

  it "start で処理を開始できる" do
    expect( @process.id ).not_to be nil
    expect( @process.running? ).to be false
    expect( @process.finished? ).to be false
    expect( @job.status ).to be :wait_for_start
    
    @process.start
    sleep 0.1
      
    expect( @process.id ).not_to be nil
    expect( @process.running? ).to be true
    expect( @process.finished? ).to be false
    expect( @job.status ).to be :running
  end
  
  it "stop で処理を停止できる" do
    @process.start
    sleep 0.1
    
    @process.stop.value
    sleep 1
    
    expect( @process.id ).not_to be nil
    expect( @process.running? ).to be false
    expect( @process.finished? ).to be true
    expect( @job.status ).to be :canceled
  end
  
  it "メッセージを送信できる" do
    @process.start
    sleep 0.1
    
    q = []
    future = @process.post_message {|job|
      q << job.status
      "x"
    }
    
    expect( future.value ).to eq "x"
    expect( q ).to eq [:running]
    
    future = @process.post_message {|job|
      raise "test"
    }
    
    expect { future.value }.to raise_error
  end
    
end