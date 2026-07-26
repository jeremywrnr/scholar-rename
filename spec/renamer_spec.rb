# frozen_string_literal: true

require 'spec_helper'

describe Renamer do
  it 'should show version number with -v' do
    out = Renamer.new ['-v', '--test']
    expect(out.version).to eq SR::VERSION
  end

  it 'should show version number with --version' do
    out = Renamer.new ['-v', '--test']
    expect(out.version).to eq SR::VERSION
  end
end
