
module Jiji
module Test  
  
  class DataBuilder
    
    
    
    def clean
      Jiji::Model::Dao::Rate.delete_all
    end
    
  end
  
end
end
