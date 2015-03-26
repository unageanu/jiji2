require 'validates_email_format_of'

module ActiveModel
  module Validations
    class EmailFormatValidator < EachValidator

      def validate_each(record, attribute, value)
        errors = ValidatesEmailFormatOf.validate_email_format(
          value, options.merge(generate_message: true)) || []
        errors.each do |error|
          record.errors.add(attribute, error, options)
        end
      end

    end
  end
end
