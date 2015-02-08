# coding: utf-8

module Jiji
module Model
module Agents
  
  module Context
    
    @@delegates = {}
    
    def self.new_context
      m = Module.new 
      define_const_missing( m )
      define_method_missing( m )
      m
    end
    
    def self._delegates
      @@delegates
    end
    def self._delegates=(delegates)
      @@delegates = delegates
    end
  
  private
    def self.define_const_missing( m )
      def m.const_missing(id)
        delegates = Context._delegates
        super unless delegates
        result = nil
        delegates.each_pair{|k,v|
          if v.const_defined?(id)
            result = v.const_get(id)
            break
          end
        }
        result ? result : super
      end
    end
    def self.define_method_missing( m )
      def m.method_missing(name,*args, &block)
        delegates = Context._delegates
        super unless delegates
        target = nil
        delegates.each_pair{|k,v|
          if v.respond_to?(name)
            target = v
            break
          end
        }
        target ? target.send( name, *args, &block ) : super
      end
    end
    
    self.define_const_missing( self )
    self.define_method_missing( self )
    
  end

end
end
end