lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "sr/version"

Gem::Specification.new do |g|
  g.author      = "Jeremy Warner"
  g.email       = "jeremywrnr@gmail.com"
  g.name        = "scholar-rename"
  g.platform    = Gem::Platform::RUBY
  g.version     = SR::Version
  g.date        = Time.now.strftime("%Y-%m-%d")
  g.summary     = 'rename pdfs based on author/title/year'
  g.description = 'rename pdfs based on author/title/year'
  g.homepage    = 'http://github.com/jeremywrnr/scholar-rename'
  g.license     = "MIT"

  g.add_development_dependency "rake"
  g.add_development_dependency "rspec"

  g.files        = Dir.glob("{bin,lib}/**/*") + %w(readme.md)
  g.executables = ['sr']
  g.require_path = 'lib'
end
