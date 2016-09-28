lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require_relative "lib/version"

Gem::Specification.new do |g|
  g.author      = "Jeremy Warner"
  g.email       = "jeremywrnr@gmail.com"
  g.name        = "scholar-rename"

  g.version     = SR::Version
  g.platform    = Gem::Platform::RUBY
  g.date        = Time.now.strftime("%Y-%m-%d")

  g.summary     = "Rename pdfs based on author/title/year."
  g.description = "Interactive tool to rename pdfs based on author/title/year."
  g.homepage    = "http://github.com/jeremywrnr/scholar-rename"
  g.license     = "MIT"

  g.add_dependency "highline"
  g.add_development_dependency "rake"
  g.add_development_dependency "rspec"

  g.files        = Dir.glob("{bin,lib}/**/*") + %w(readme.md)
  g.executables = ["scholar-rename"]
  g.require_path = "lib"
end
