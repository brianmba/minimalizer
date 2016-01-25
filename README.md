# Write Ruby on Rails applications more easily with Minimalizer

[![Gem Version](https://badge.fury.io/rb/minimalizer.svg)](http://badge.fury.io/rb/minimalizer)

Minimalizer is a lightweight Ruby on Rails engine that enables you to write more
minimal Ruby on Rails applications. Minimalizer convenience methods help you
write simpler model and controller tests and declare basic controller behaviors
with ease.

## Model Test Helpers

Added to `ActiveSupport::TestCase`:

* `assert_errors`
* `refute_errors`
* `validation_context`

See `lib/minimalizer/model_test_helpers.rb` for more detailed documentation.

## Controller Test Helpers

Added to `ActionController::TestCase`:

* `assert_redirect`
* `assert_render`
* `assert_flash`

See `lib/minimalizer/controller_test_helpers.rb` for more detailed
documentation.

## Controller Helpers

Added to `ActionController::Base`:

* `self.new_actions`
* `self.member_actions`
* `respond_to_boolean`
* `respond_to_resource`
* `create_resource`
* `update_resource`
* `destroy_resource`
* `enable_resource`
* `disable_resource`
* `mass_update_resources`

See `lib/minimalizer/controller_helpers.rb` for more detailed documentation.

## License

Minimalizer is released under the MIT license. Copyright 2015 Theodore Kimble.
