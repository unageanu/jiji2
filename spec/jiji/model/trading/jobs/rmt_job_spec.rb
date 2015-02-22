# coding: utf-8

require 'jiji/test/test_configuration'

# describe Jiji::Model::Trading::Jobs::RMTJob do
#   
  # before(:example) do
    # @data_builder = Jiji::Test::DataBuilder.new
    # @container    = Jiji::Test::TestContainerFactory.instance.new_container
#     
    # @job = @container.lookup(:rmt_job)
    # @rmt_broker_setting = @container.lookup(:rmt_broker_setting)
    # @rmt_broker_setting.set_active_securities(:mock, {})
#     
    # @mock_plugin =  Jiji::Test::Mock::MockSecuritiesPlugin.instance
  # end
#   
  # after(:example) do
    # @data_builder.clean
  # end
#   
  # it "正常終了" do
#     
    # expect( @job.has_next ).to be false
    # expect( @job.status ).to be :wait_for_start
#     
    # @job.prepare_running
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
# 
    # @job.do_next
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
#     
    # @job.do_next
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
#     
    # @job.post_running
    # expect( @job.has_next ).to be false
    # expect( @job.status ).to be :finished
#     
  # end
#   
  # it "キャンセルで終了" do
#     
    # expect( @job.has_next ).to be false
    # expect( @job.status ).to be :wait_for_start
#     
    # @job.prepare_running
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
# 
    # @job.do_next
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
#     
    # @job.do_next
    # expect( @job.has_next ).to be true
    # expect( @job.status ).to be :running
#     
    # @job.request_cancel
    # expect( @job.has_next ).to be false
    # expect( @job.status ).to be :wait_for_cancel
#     
    # @job.post_running
    # expect( @job.has_next ).to be false
    # expect( @job.status ).to be :cancelled
#     
  # end
#   
  # it "next_rateでエラーになっても処理が継続される" do
#     
    # @mock_plugin.seed = :error
    # @job.do_next
    # @job.do_next
#     
  # end
#   
# end