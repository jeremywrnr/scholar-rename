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

  it 'should grab the right year automatically' do
    year =`./bin/scholar-rename --test-year spec/kevin.pdf`
    expect(year.trim).to "2019"
  end

  it 'should test real files' do
    system ("./bin/scholar-rename --auto spec/test.pdf")
    expect($?.exitstatus).to eq 0
  end

  it 'should test real files with spaces' do
    system ("./bin/scholar-rename --auto spec/test\ space.pdf")
    expect($?.exitstatus).to eq 0
  end

  it 'should reject non-existent files' do
    system ("./bin/scholar-rename --auto 0 spec/fake.pdf")
    expect($?.exitstatus).to eq 1
  end
end
