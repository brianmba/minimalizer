require File.expand_path('../lib/minimalizer/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'minimalizer'
  s.version     = Minimalizer::VERSION
  s.homepage    = 'https://github.com/theodorekimble/minimalizer'
  s.license     = 'MIT'
  s.summary     = 'Write Ruby on Rails applications more easily with Minimalizer'
  s.authors     = ['Theodore Kimble']
  s.email       = ['mail@theodorekimble.com']

  s.description = <<-EOF
    Minimalizer is a lightweight Ruby on Rails engine that enables you to write
    more minimal Ruby on Rails applications. Minimalizer convenience methods
    help you write simpler model and controller tests and declare basic
    controller behaviors with ease.
  EOF

  s.files = Dir['MIT-LICENSE', 'README.md', 'Rakefile', 'lib/**/*']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rack-test', '~> 0'

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'active_model-errors_details', '~> 1.1'
end
