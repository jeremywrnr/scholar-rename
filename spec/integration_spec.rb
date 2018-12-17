require 'spec_helper'

describe "bin/scholar-renamer" do
  it 'should show help' do
    system("./bin/scholar-rename")
    expect($?.exitstatus).to eq 0
  end

  it 'should show versions -v/--version' do
    system ("./bin/scholar-rename -v")
    expect($?.exitstatus).to eq 0
    system ("./bin/scholar-rename --version")
    expect($?.exitstatus).to eq 0
  end

  it 'should show formats' do
    system ("./bin/scholar-rename --format")
    expect($?.exitstatus).to eq 0
  end

  it 'should test real file' do
    system ("./bin/scholar-rename --format 0 spec/test.pdf")
    expect($?.exitstatus).to eq 0
    system ("./bin/scholar-rename --format 0 spec/fake.pdf")
    expect($?.exitstatus).to eq 1
  end
end
