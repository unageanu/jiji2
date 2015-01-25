# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::PositionRepository do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    
    @container            = Jiji::Test::TestContainerFactory.instance.new_container
    @back_test_repository = @container.lookup(:back_test_repository)
    @position_repository  = @container.lookup(:position_repository)
    @time_source          = @container.lookup(:time_source)
    
    @data_builder.register_ticks(5, 60)
    
    @test1 = @data_builder.register_back_test( 1, @back_test_repository )
    @test2 = @data_builder.register_back_test( 2, @back_test_repository )
    @test3 = @data_builder.register_back_test( 3, @back_test_repository )
    
    register_rmt_positions
    register_back_Test_positions( @test1._id )
    register_back_Test_positions( @test2._id )
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  def register_rmt_positions
    register_positions( nil )
  end
  def register_back_Test_positions( back_test_id )
    register_positions( back_test_id )
  end
  def register_positions( back_test_id )
    100.times {|i|
       position = @data_builder.new_position(i, back_test_id)
       position.close if i < 50
    }
  end
  
  it "ソート条件、取得数を指定して、一覧を取得できる" do
    positions = @position_repository.get_positions( nil )
    
    expect( positions.length).to eq(20)
    expect( positions[0].back_test_id  ).to eq( nil )
    expect( positions[0].entered_at  ).to eq( Time.at( 0) )
    expect( positions[19].back_test_id ).to eq( nil )
    expect( positions[19].entered_at ).to eq( Time.at(19) )
    
    
    positions = @position_repository.get_positions( 
        nil, {:entered_at=>:desc} )
    
    expect( positions.size ).to eq(20)
    expect( positions[0].back_test_id  ).to eq( nil )
    expect( positions[0].entered_at  ).to eq( Time.at(99) )
    expect( positions[19].back_test_id ).to eq( nil )
    expect( positions[19].entered_at ).to eq( Time.at(80) )
    
    
    positions = @position_repository.get_positions( 
        nil, {:entered_at=>:desc}, 10, 30 )
    
    expect( positions.size ).to eq(30)
    expect( positions[0].back_test_id  ).to eq( nil )
    expect( positions[0].entered_at  ).to eq( Time.at(89) )
    expect( positions[29].back_test_id ).to eq( nil )
    expect( positions[29].entered_at ).to eq( Time.at(60) )
    
    
    positions = @position_repository.get_positions( 
        nil, {:entered_at=>:asc}, 10, 30 )
    
    expect( positions.size ).to eq(30)
    expect( positions[0].back_test_id  ).to eq( nil )
    expect( positions[0].entered_at  ).to eq( Time.at(10) )
    expect( positions[29].back_test_id ).to eq( nil )
    expect( positions[29].entered_at ).to eq( Time.at(39) )
    
    
    positions = @position_repository.get_positions( @test1._id )
    
    expect( positions.size ).to eq(20)
    expect( positions[0].back_test_id  ).to eq( @test1._id )
    expect( positions[0].entered_at  ).to eq( Time.at(0) )
    expect( positions[19].back_test_id ).to eq( @test1._id )
    expect( positions[19].entered_at ).to eq( Time.at(19) )
    
    
    positions = @position_repository.get_positions( 
        @test1._id, {:exited_at=>:desc}, 10, 30 )
    
    expect( positions.size ).to eq(30)
    expect( positions[0].back_test_id  ).to eq( @test1._id )
    expect( positions[0].entered_at  ).to eq( Time.at(39) )
    expect( positions[29].back_test_id ).to eq( @test1._id )
    expect( positions[29].entered_at ).to eq( Time.at(10) )
    
    
    positions = @position_repository.get_positions( @test3._id )
    
    expect( positions.size ).to eq(0)
  end
  
  it "アクティブなRMTの建玉を取得できる" do
    positions = @position_repository.get_living_positions_of_rmt
    
    expect( positions.size ).to eq(50)
    expect( positions[0].back_test_id  ).to eq( nil )
    expect( positions[0].entered_at  ).to eq( Time.at(50) )
    expect( positions[0].exited_at  ).to eq( nil )
    expect( positions[49].back_test_id ).to eq( nil )
    expect( positions[49].entered_at ).to eq( Time.at(99) )
    expect( positions[49].exited_at  ).to eq( nil )
  end
  
  it "不要になったバックテストの建玉を削除できる" do
    positions = @position_repository.get_positions( @test1._id )
    expect( positions.size ).to eq(20)
    positions = @position_repository.get_positions( @test2._id )
    expect( positions.size ).to eq(20)
    
    @position_repository.delete_all_positions_of_back_test( @test1._id )
    
    positions = @position_repository.get_positions( @test1._id )
    expect( positions.size ).to eq(0)
    positions = @position_repository.get_positions( @test2._id )
    expect( positions.size ).to eq(20)
  end
  
  it "決済済みになったRMTの建玉を削除できる"  do
    positions = @position_repository.get_positions( )
    expect( positions.size ).to eq(20)
    
    @position_repository.delete_closed_positions_of_rmt( Time.at(40) )
    
    positions = @position_repository.get_positions( )
    expect( positions.size ).to eq(20)
    expect( positions[0].back_test_id ).to eq( nil )
    expect( positions[0].entered_at ).to eq( Time.at(40) )
    expect( positions[0].exited_at ).to eq( Time.at(40) )
    expect( positions[19].back_test_id ).to eq( nil )
    expect( positions[19].entered_at ).to eq( Time.at(59) )
    expect( positions[19].exited_at ).to eq( nil )
    
    @position_repository.delete_closed_positions_of_rmt( Time.at(60) )
        
    positions = @position_repository.get_positions( )
    expect( positions.size ).to eq(20)
    expect( positions[0].back_test_id ).to eq( nil )
    expect( positions[0].entered_at ).to eq( Time.at(50) )
    expect( positions[0].exited_at ).to eq( nil )
    expect( positions[19].back_test_id ).to eq( nil )
    expect( positions[19].entered_at ).to eq( Time.at(69) )
    expect( positions[19].exited_at ).to eq( nil )
  end
  
end