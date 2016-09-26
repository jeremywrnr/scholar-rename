lib = File.expand_path("../../../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

# helper for rspec
require "scholar-rename"
require "fileutils"
require "find"

# hacky mute-able puts
$muted = true
def puts(*x)
  $muted? x.join : x.flat_map { |y| print y + "\n" }
end

