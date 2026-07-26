# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |g|
  g.author      = 'Jeremy Warner'
  g.email       = 'jeremywrnr@gmail.com'
  g.name        = 'scholar-rename'

  g.version     = SR::VERSION
  g.platform    = Gem::Platform::RUBY
  g.required_ruby_version = '>= 3.0'

  g.summary     = 'Rename pdfs based on author/title/year.'
  g.description = 'Interactive tool to rename pdfs based on author/title/year.'
  g.homepage    = 'http://github.com/jeremywrnr/scholar-rename'
  g.license     = 'MIT'

  g.metadata = {
    'source_code_uri' => 'https://github.com/jeremywrnr/scholar-rename',
    'bug_tracker_uri' => 'https://github.com/jeremywrnr/scholar-rename/issues'
  }

  g.add_development_dependency 'rspec'
  g.add_development_dependency 'rubocop'
  g.add_development_dependency 'webmock'

  g.files = Dir.glob('{bin,lib}/**/*') + %w[readme.md]
  g.executables = ['scholar-rename']
  g.require_path = 'lib'
end
