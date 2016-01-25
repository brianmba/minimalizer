require 'action_controller'
require 'active_support/concern'

module Minimalizer
  module ControllerHelpers
    extend ActiveSupport::Concern

    class_methods do
      # Convenience method for specifying/excluding new actions in a before
      # filter.
      #
      #   before_action only: new_actions do
      #     @record = Record.new
      #   end
      def new_actions
        %i[new create]
      end

      # Convenience method for specifying/excluding member actions in a before
      # filter.
      #
      #   before_action only: member_actions do
      #     @record = Record.find(params[:id])
      #   end
      def member_actions
        %i[show edit update delete destroy]
      end
    end

    # Respond to a boolean condition.
    #
    # If the condition is truthful, set the notice flash, if present, and
    # redirect to the :location option, if present.
    #
    # If the condition is not truthful, set the alert flash, if present, and
    # render the :template option or the default action. If the :redirect option
    # is provided, redirect there instead. If the :redirect option equals true,
    # then redirect to the :location option instead.
    #
    #   def create
    #     respond_to_boolean(value, location: '/home')
    #   end
    #
    # Provide callbacks to :on_succeed or :on_fail and all methods will be
    # called on the containing controller. Callbacks may be provided as a symbol
    # or array of symbols.
    #
    #   def create
    #     respond_to_boolean(value, location: '/home', on_succeed: :do_something)
    #   end
    #
    # By default the  notice and alert values will be set to the I18n
    # translations of “.notice” and “.alert”, respectively. Pass a string to
    # render that value directly, a hash to use that value as the locals during
    # the translation, or a false-like value to skip setting that flash value.
    def respond_to_boolean(condition, location: nil, template: nil, redirect: false, on_succeed: [], on_fail: [], notice: true, alert: true)
      if condition
	flash.notice = translate_key(:notice, notice)
	redirect_to location if location
	Array(on_succeed).each { |method| send(method) }
      elsif redirect
	flash.alert = translate_key(:alert, alert)
	location = redirect unless redirect == true
	redirect_to location if location
	Array(on_fail).each { |method| send(method) }
      else
	flash.now.alert = translate_key(:alert, alert)
	render template || { create: :new, update: :edit, destroy: :delete }[action_name.to_sym], status: 422
	Array(on_fail).each { |method| send(method) }
      end
    end

    # Convenience method for responding to the boolean result of a model’s
    # method. The model is extracted from the provided resource chain, and
    # unless a :location option is provided the resource_chain will be used as
    # the redirect location. See #respond_to_boolean for more information.
    #
    #   def create
    #     respond_to_boolean([:namespace, @resource], :save, { attribute: 1 })
    #   end
    def respond_to_resource(resource_chain, method, arguments = nil, options = {})
      if resource_chain.is_a?(Array)
	model = Array(resource_chain).reject { |o| [String, Symbol].include?(o.class) }.last
      else
	model = resource_chain
      end

      yield(model, options) if block_given?

      unless options.key?(:location)
	options[:location] = resource_chain
      end

      if arguments.is_a?(Hash)
	respond_to_boolean(model.send(method, arguments), options)
      else
	respond_to_boolean(model.send(method, *arguments), options)
      end
    end

    # Convenience method for creating a new ActiveRecord-like resource.
    # Attributes will be assigned to the model prior to saving. See
    # #respond_to_resource for more information.
    def create_resource(resource_chain, attributes, options = {})
      context = options.slice!(:context) if options.key?(:context)
      respond_to_resource(resource_chain, :save, context, options) do |model|
	model.assign_attributes(attributes)
      end
    end

    # Convenience method for updating an existing ActiveRecord-like resource.
    # See #respond_to_resource for more information.
    def update_resource(resource_chain, attributes, options = {})
      respond_to_resource(resource_chain, :update, attributes, options)
    end

    # Convenience method for destroying an existing ActiveRecord-like resource.
    # See #respond_to_resource for more information.
    def destroy_resource(resource_chain, options = {})
      respond_to_resource(resource_chain, :destroy, nil, options) do |model, options|
	options[:location] ||= Array(resource_chain)[0..-2] + [model.model_name.plural.to_sym]
      end
    end

    # Convenience method for updating an existing ActiveRecord-like resource’s
    # attribute to true. See #respond_to_resource for more information.
    def enable_resource(resource_chain, attribute, options = {})
      respond_to_resource(resource_chain, :update, { attribute => true }, options)
    end

    # Convenience method for updating an existing ActiveRecord-like resource’s
    # attribute to false. See #respond_to_resource for more information.
    def disable_resource(resource_chain, attribute, options = {})
      respond_to_resource(resource_chain, :update, { attribute => false }, options)
    end

    # Convenience method for updating an ActiveRecord::Relation-like
    # collections’ attributes. Use the :permit option to limit the allowed
    # attributes. See #respond_to_resource for more information.
    def mass_update_resources(resources_chain, attributes, options = {})
      attributes_values = attributes.values

      if permit = options.delete(:permit)
	attributes_values.map! { |attr| ActionController::Parameters.new(attr).permit(permit) }
      end

      respond_to_resource(resources_chain, :update, [attributes.keys, attributes_values], options) do |models, options|
	options[:location] ||= Array(resources_chain)[0..-2] + [models.first.model_name.plural.to_sym]
      end
    end

    private

    # Returns a string for the value. If the value is a string it will be
    # returned. If the value is a hash or is truthful the I18n translation for
    # that key will be rendered with the value as its locals. Include a local of
    # :_html to render the html version of the translation.
    def translate_key(key, value)
      if value.is_a?(String)
	value
      elsif value.kind_of?(Hash)
	t(".#{key}#{'_html' if value.delete(:_html)}", value)
      elsif value
	t(".#{key}")
      end
    end
  end
end

ActionController::Base.send :include, Minimalizer::ControllerHelpers
