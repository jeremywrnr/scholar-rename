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

  it 'should show formats with --format' do
    raise "TODO - implement non-interactive version"
    #out = Renamer.new '--format'
    #expect(out.formats.instance_of? Array).to eq true
  end

  it 'should select format with --format number' do
    raise "TODO - implement non-interactive version"
    #out = Renamer.new '--format', ' 1', "spec/test.pdf"
    #expect(out.format).to eq 1
  end
end
