lib = File.expand_path('../../lib/', __FILE__)
bin = File.expand_path('../../bin/', __FILE__)
$:.unshift lib unless $:.include?(lib)
$:.unshift bin unless $:.include?(bin)

require_relative '../lib/version'
require_relative '../lib/selector'
require_relative '../lib/renamer'

require 'rubygems'
require 'rspec'
