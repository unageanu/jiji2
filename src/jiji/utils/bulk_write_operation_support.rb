module Jiji::Utils
  module BulkWriteOperationSupport

    KEY = BulkWriteOperationSupport.name

    def save
      if BulkWriteOperationSupport.in_transaction?
        BulkWriteOperationSupport.transaction << self
      else
        super
      end
    end

    def self.in_transaction?
      !transaction.nil?
    end

    def self.begin_transaction
      Thread.current[KEY] = Transaction.new
    end

    def self.end_transaction
      return unless in_transaction?
      transaction.execute
      Thread.current[KEY] = nil
    end

    def self.transaction
      Thread.current[KEY]
    end

    def create_insert_operation
      { :insert_one => as_document }
    end

    def create_update_operation
      {
        :update_one => {
          :filter => { :_id => id },
          :update => {'$set' => collect_changed_values }
        }
      }
    end

    private

    def collect_changed_values
      changes.each_with_object({}) do |change, r|
        r[change[0].to_sym] = change[1][1]
      end
    end

    class Transaction

      def initialize
        @targets = {}
      end

      def <<(model)
        targets_of( model.class )[model.object_id] = model
      end

      def execute
        until @targets.empty?
          model_class = @targets.keys.first
          execute_bulk_write_operations(model_class)
        end
      end

      def size
        @targets.values.reduce(0) {|a, e| a + e.length }
      end

      private

      def targets_of( model_class )
        @targets[model_class] ||= {}
      end

      def execute_bulk_write_operations(model_class)
        return unless @targets.include?(model_class)
        execute_parent_object_bulk_write_operations_if_exists(model_class)

        client = model_class.mongo_client[model_class.collection_name]
        operations = create_operations(@targets[model_class].values)
        client.bulk_write(operations) unless operations.empty?

        @targets.delete model_class
      end

      def execute_parent_object_bulk_write_operations_if_exists(model_class)
        parents = model_class.reflect_on_all_associations(:belongs_to)
        parents.each do |m|
          klass = m.klass
          execute_bulk_write_operations(klass)
        end
      end

      def create_operations(targets)
        targets.each_with_object([]) do |model, array|
          if model.new_record?
            model.new_record = false
            array << model.create_insert_operation
          else
            array << model.create_update_operation if model.changed?
          end
        end
      end

    end

  end
end
