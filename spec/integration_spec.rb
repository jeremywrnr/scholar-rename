require 'spec_helper'

describe "bin/scholar-renamer" do
  it 'should show help' do
    system("../bin/scholar-rename`")
    expect($?.success?).to eq true
  end

  it 'should show versions -v/--version' do
    system ("../bin/scholar-rename -v")
    expect($?.success?).to eq true
    system ("../bin/scholar-rename --version")
    expect($?.success?).to eq true
  end

  it 'should show formats' do
    system ("../bin/scholar-rename --format")
    expect($?.success?).to eq true
  end
end
