# frozen_string_literal: true

require_relative 'lib/version'

repo_url = 'https://github.com/jeremywrnr/scholar-rename'

Gem::Specification.new do |g|
  g.author      = 'Jeremy Warner'
  g.email       = 'jeremywrnr@gmail.com'
  g.name        = 'scholar-rename'

  g.version     = SR::VERSION
  g.platform    = Gem::Platform::RUBY
  g.required_ruby_version = '>= 3.0'

  g.summary     = 'Rename pdfs based on author/title/year.'
  g.description = 'Interactive tool to rename pdfs based on author/title/year.'
  g.homepage    = repo_url
  g.license     = 'MIT'

  g.metadata = {
    'source_code_uri' => repo_url,
    'bug_tracker_uri' => "#{repo_url}/issues"
  }

  g.add_development_dependency 'rspec'
  g.add_development_dependency 'rubocop'
  g.add_development_dependency 'webmock'

  g.files = Dir.glob('{bin,lib}/**/*') + %w[readme.md]
  g.executables = ['scholar-rename']
  g.require_path = 'lib'
end
