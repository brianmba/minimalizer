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

    # Create a new resource with the given attributes. If successful, set the
    # ".notice" flash and redirect to the newly created resource; otherwise,
    # set the ".alert" flash and render the new template with a 422 HTTP status
    # reponse.
    #
    #   def create
    #     create_resource @record, record_params
    #   end
    #
    # A resource array can be provided to affect the redirect location. Only
    # the last resource will be saved.
    #
    #   def create
    #     create_resource [@parent, @record], record_params
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def create
    #     create_resource @record, record_params, location: :records
    #   end
    #
    # Passing a block will yield true if the model saves successfully, false
    # otherwise.
    #
    #   def create
    #     create_resource @record, record_params do |success|
    #       if sucess
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def create_resource(resource, attributes, location: nil)
      model = resource.is_a?(Array) ? resource.last : resource
      model.assign_attributes attributes

      if model.save
        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location || resource
      else
        flash.now.alert = t('.alert')
        response.status = 422
        yield false if block_given?
        render :new
      end
    end


    # Update an existing resource with the given attributes. If successful,
    # set the ".notice" flash and redirect to the resource; otherwise, set the
    # ".alert" flash and render the edit template with a 422 HTTP status
    # response.
    #
    #   def update
    #     update_resource @record, record_params
    #   end
    #
    # A resource array can be provided to affect the redirect location. Only
    # the last resource will be updated.
    #
    #   def update
    #     update_resource [@parent, @record], record_params
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def update
    #     update_resource @record, record_params, location: :records
    #   end
    #
    # Passing a block will yield true if the model updates successfully, false
    # otherwise.
    #
    #   def update
    #     update_resource @record, record_params do |success|
    #       if sucess
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def update_resource(resource, attributes, location: nil)
      model = resource.is_a?(Array) ? resource.last : resource

      if model.update(attributes)
        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location || resource
      else
        flash.now.alert = t('.alert')
        response.status = 422
        yield false if block_given?
        render :edit
      end
    end

    # Delete the given model.
    #
    # If the operation succeeds, provide a successful flash notice and
    # redirect to the provided location (if given) or to the pluralized path
    # of the original resource.
    #
    # If the operation fails, provide a failed flash alert. Then, if the
    # :delete action exists, render the edit action with an
    # :unprocessable_entity HTTP status; if the action does not exist,
    # redirect to the original resource.
    #
    #
    #
    # Destroy an existing resource. If successful, set the ".notice" flash and
    # redirect to the symbolized, plural name of the resource; otherwise, set
    # the ".alert" flash and render the delete template with a 422 HTTP status
    # response; if the delete action is not defined, instead redirect the
    # resource.
    #
    #   def destroy
    #     destroy_resource @record
    #   end
    #
    # A resource array can be provided to affect the redirect location. Only
    # the last resource will be destroyed.
    #
    #   def destroy
    #     destroy_resource [@parent, @record]
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def destroy
    #     destroy_resource @record, location: :root
    #   end
    #
    # Passing a block will yield true if the model destroys successfully, false
    # otherwise.
    #
    #   def destroy
    #     destroy_resource @record do |success|
    #       if sucess
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def destroy_resource(resource, location: nil)
      model = resource.is_a?(Array) ? resource.last : resource

      if model.destroy
        if !location
          location = Array(resource)[0..-2] + [model.model_name.plural.to_sym]
        end

        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location
      else
        if respond_to?(:delete)
          flash.now.alert = t('.alert')
          response.status = 422
          yield false if block_given?
          render :delete
        else
          flash.alert = t('.alert')
          yield false if block_given?
          redirect_to resource
        end
      end
    end

    # Reorder the given models on the order attribute by the given attributes.
    #
    # If all operations succeed, provide a successful flash notice and
    # redirect to the provided location (if given) or to the pluralized path
    # of the first original resource.
    #
    # If any operation fails, provide a failed flash alert and render the
    # :edit action with an :unprocessable_entity HTTP status.
    #
    #   def update
    #     reorder_resources @records, record_params
    #   end
    #
    # An optional :attribute argument will override the default reording
    # attribute (:position).
    #
    #   def update
    #     reorder_resources @records, record_params, attribute: :ranking
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def update
    #     reorder_resources @records, record_params, location: :root
    #   end
    #
    # Passing a block will yield true if all models are reordered successfully,
    # false otherwise.
    #
    #   def update
    #     reorder_resources @records, record_params do |success|
    #       if sucess
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def reorder_resources(resources, attributes, attribute: :position, location: nil)
      models = resources.is_a?(Array) && (resources.last.is_a?(Array) || resources.last.is_a?(ActiveRecord::Relation)) ? resources.last : resources

      models.each do |model|
        model.update(attribute => attributes[model.id.to_s].to_i)
      end

      if models.all? { |model| model.errors.empty? }
        if !location
          if models.any?
            location = Array(resources)[0..-2] + [models.first.model_name.plural.to_sym]
          else
            raise ArgumentError, 'Must provide one or more resources or the :location argument'
          end
        end

        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location
      else
        flash.now.alert = t('.alert')
        response.status = 422
        yield false if block_given?
        render :edit
      end
    end

    # Toggle the given model attribute on.
    #
    # If the operation succeeds, provide a successful flash notice; otherwise,
    # provide a failed flash alert. Redirect to the provided location (if
    # given) or to the initial resource.
    #
    #   def update
    #     toggle_resource_boolen_on @record, :active
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def update
    #     toggle_resource_boolen_on @record, :active, location: :records
    #   end
    #
    # Passing a block will yield true if the model is updated successfully,
    # false otherwise.
    #
    #   def update
    #     toggle_resource_boolen_on @record, :active do |success|
    #       if success
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def toggle_resource_boolean_on(resource, attribute, location: nil)
      model = resource.is_a?(Array) ? resource.last : resource

      if model.update(attribute => true)
        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location || resource
      else
        flash.alert = t('.alert')
        yield false if block_given?
        redirect_to location || resource
      end
    end

    # Toggle the given model attribute off.
    #
    # If the operation succeeds, provide a successful flash notice; otherwise,
    # provide a failed flash alert. Redirect to the provided location (if
    # given) or to the initial resource.
    #
    #   def update
    #     toggle_resource_boolen_off @record, :active
    #   end
    #
    # An optional :location argument will override the redirect location.
    #
    #   def update
    #     toggle_resource_boolen_off @record, :active, location: :records
    #   end
    #
    # Passing a block will yield true if the model is updated successfully,
    # false otherwise.
    #
    #   def update
    #     toggle_resource_boolen_off @record, :active do |success|
    #       if success
    #         # something
    #       else
    #         # something
    #       end
    #     end
    #   end
    def toggle_resource_boolean_off(resource, attribute, location: nil)
      model = resource.is_a?(Array) ? resource.last : resource

      if model.update(attribute => false)
        flash.notice = t('.notice')
        yield true if block_given?
        redirect_to location || resource
      else
        flash.alert = t('.alert')
        yield false if block_given?
        redirect_to location || resource
      end
    end
  end
end

ActionController::Base.send :include, Minimalizer::ControllerHelpers
