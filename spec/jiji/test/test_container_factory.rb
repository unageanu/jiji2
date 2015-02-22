# coding: utf-8

require 'jiji/composing/container_factory'

module Jiji
module Test
  
  class TestContainerFactory < Jiji::Composing::ContainerFactory
    
    include Jiji::Model
    
    def configure_model( container )
      super
    end
    
  end

end
end