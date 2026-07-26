# justfile for scholar-rename

gem_name := "scholar-rename"
version := `ruby -r./lib/version.rb -e 'puts SR::VERSION'`

# Run tests with RSpec
spec:
    bundle exec rspec --color --format documentation

# Format/lint code with RuboCop (auto-fixes)
lint:
    bundle exec rubocop -A

# Check lint without modifying files (for CI)
lint-check:
    bundle exec rubocop

# Build and install the gem
build:
    gem build {{gem_name}}.gemspec
    gem install ./{{gem_name}}-{{version}}.gem

# Clean up gem files
clean:
    @echo "cleaning gems..."
    rm -fv *.gem

# Clean, build, and push gem to RubyGems
push: ci clean build
    gem push {{gem_name}}-{{version}}.gem

# Run CI checks
ci: spec lint-check

# List all available recipes
help:
    @just --list
