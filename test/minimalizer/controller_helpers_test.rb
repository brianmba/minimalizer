require 'test_helper'

class Minimalizer::ControllerHelpersTest < Minitest::Test
  def test_new_actions
    assert_equal %i[new create], ActionController::Base.new_actions
  end

  def test_member_actions
    assert_equal %i[show edit update delete destroy], ActionController::Base.member_actions
  end
end
