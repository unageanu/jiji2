module Jiji::Utils
  class PersistenceUtils

    def self.get_or_create(get, create)
      entity = get.call
      return entity if entity
      begin
        create.call
      rescue Mongo::Error::OperationFailure => e
        raise e unless e.to_s =~ /E11000/
        return get.call || Jiji::Errors.illegal_state(e.to_s)
      end
    end

  end
end
