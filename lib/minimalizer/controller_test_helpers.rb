require 'action_controller'
require 'active_support/concern'

module Minimalizer
  module ControllerTestHelpers
    extend ActiveSupport::Concern

    private

    # Assert the correct redirect location is given; optionally test the
    # response status and flash messages.
    def assert_redirect(location, status: 302, alert: nil, notice: nil)
      assert_redirected_to location
      assert_response status
      assert_flash :alert, alert if alert
      assert_flash :notice, notice if notice
    end

    # Assert the correct template is rendered; optionally test the response
    # status and flash messages.
    def assert_render(template, status: 200, alert: nil, notice: nil)
      assert_template template
      assert_response status
      assert_flash :alert, alert if alert
      assert_flash :notice, notice if notice
    end

    # Assert that the flash variant (e.g. :notice) is equal to the local
    # translation for the given key.
    def assert_flash(variant, key)
      assert_equal I18n.t(key, scope: local_translation_scope), flash[variant]
    end

    # Local translation scope for the current controller and action.
    def local_translation_scope
      [@controller.controller_path.split('/'), @controller.action_name].flatten.compact.join('.')
    end
  end
end

ActionController::TestCase.send :include, Minimalizer::ControllerTestHelpers
