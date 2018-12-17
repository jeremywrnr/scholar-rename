# rspec unit testing for modname

require 'spec_helper'

describe Renamer do
  it 'should show version number with -v' do
    out = Renamer.new '-v'
    expect(out.vers).to eq SR::Version
  end

  it 'should show format number with --format' do
    raise false
  end

  it 'should use format number with --format [number]' do
    raise false
  end
end
