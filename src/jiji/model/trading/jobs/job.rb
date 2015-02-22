# coding: utf-8

module Jiji::Model::Trading::Jobs

class Job
  
  attr :future
  
  def initialize
    @future = Jiji::Utils::Future.new
  end
  def exec(context, queue)
    begin 
      @future.value = call(context, queue)
    rescue Exception => e 
      @future.error = e
      raise e
    end
  end
  def call(context, queue)
  end
  
  def self.create_from( &block ) 
    ProcJob.new( &block )
  end
end

class ProcJob < Job
  def initialize( &block )
    super()
    @block = block
  end
  def call( trading_context, queue )
    @block.call( trading_context, queue )
  end
end

end
