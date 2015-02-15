# coding: utf-8

require 'encase'

module Jiji::Model::Trading
class PositionRepository
  
  include Encase
  include Jiji::Errors
  
  def get_positions( back_test_id=nil, 
    sort_order={:entered_at=>:asc}, offset=0, limit=20 )
    query = Jiji::Utils::Pagenation::Query.new(
      {:back_test_id=>back_test_id}, sort_order, offset, limit)
    query.execute( Position ).map {|x| x}
  end
  
  def get_living_positions_of_rmt
    query = Jiji::Utils::Pagenation::Query.new(
      {:back_test_id=>nil, :status=>:live}, {:entered_at=>:asc})
    query.execute( Position ).map {|x| x}
  end
  
  def delete_all_positions_of_back_test( back_test_id )
    Position.where({
      :back_test_id=>back_test_id
    }).delete
  end
  
  def delete_closed_positions_of_rmt( exited_before )
    Position.where({
      :back_test_id  => nil,
      :status        => :closed, 
      :exited_at.lt  => exited_before
    }).delete
  end
  
end
end
