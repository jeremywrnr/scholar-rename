require 'spec_helper'

describe Renamer do
  it 'should show version number with -v' do
    out = Renamer.new '-v'
    expect(out.vers).to eq SR::Version
  end

  it 'should show version number with --version' do
    out = Renamer.new '--version'
    expect(out.vers).to eq SR::Version
  end
end
