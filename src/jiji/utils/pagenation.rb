require 'date'

module Jiji
module Utils
module Pagenation
  
  class Query
    attr_accessor :filter_conditions, :sort_by, :offset, :limit
    
    def initialize( filter_conditions=nil, 
      sort_by=nil, offset=nil, limit=nil )
      @filter_conditions = filter_conditions
      @sort_by           = sort_by
      @offset            = offset
      @limit             = limit
    end
    
    def execute( data_type )
      queryable = data_type
      queryable = apply_filter_conditions( queryable )
      queryable = apply_sort_order(queryable)
      queryable = apply_offset(queryable)
      queryable = apply_limit(queryable)
      queryable
    end
    
  private
    def apply_filter_conditions( queryable )
      filter_conditions ? queryable.where( filter_conditions ) : queryable.all
    end
    def apply_sort_order(queryable)
      sort_by != nil ? queryable.order_by(sort_by) : queryable
    end
    def apply_offset(queryable)
      offset != nil ? queryable.skip(offset) : queryable
    end
    def apply_limit(queryable)
      limit != nil ? queryable.limit(limit) : queryable
    end
  end

end
end
end