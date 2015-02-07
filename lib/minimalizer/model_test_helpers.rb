require 'active_model'
require 'active_model/errors_details'
require 'active_support/concern'

module Minimalizer
  module ModelTestHelpers
    extend ActiveSupport::Concern

    private

    # Assert that the given model‘s attribute contains errors. If error details
    # are provided, assert that each provided set of details is found on the
    # model’s attribute.
    def assert_errors(attribute, model, *error_details)
      model.valid?(@_validation_context)
      assert_not_empty model.errors[attribute]

      if error_details.any?
        model_error_details = model.errors.details[attribute]
        model_errors = model_error_details.map { |d| d[:error] }

        error_details.each do |details|
          if details.keys == [:error]
            assert_includes model_errors, details[:error], "Expected error details to include error #{details[:error]}; found #{model_errors}."
          else
            assert_includes model_error_details, details, "Expected error details to include #{details}: Found #{model_error_details}."
          end
        end
      end
    end

    # Refute that the given model‘s attribute contains any errors.
    def refute_errors(attribute, model)
      model.valid?(@_validation_context)
      assert_empty model.errors[attribute]
    end

    # Set the validation context used during model error assertions.
    def validation_context(context)
      @_validation_context = context
      yield
      @_validation_context = nil
    end
  end
end

ActiveSupport::TestCase.send :include, Minimalizer::ModelTestHelpers
