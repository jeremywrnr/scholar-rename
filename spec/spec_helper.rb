# frozen_string_literal: true

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../lib/version'
require_relative '../lib/scholar_lookup'
require_relative '../lib/selector'
require_relative '../lib/renamer'
