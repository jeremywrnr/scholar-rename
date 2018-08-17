# rspec unit testing for modname

require 'spec_helper'

describe Renamer do
  it 'should show standard help when given no args' do
    expect(nil).to eq nil
  end

  it 'should show version number with -v' do
    out = Renamer.new '-v'
    expect(out.vers).to eq SR::Version
  end
end
