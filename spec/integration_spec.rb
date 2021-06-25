require "spec_helper"

describe "bin/scholar-renamer" do
  def call(arg)
    out = `./bin/scholar-rename #{arg}`
    out.strip!
    out
  end

  it "should show help" do
    system("./bin/scholar-rename --help --test")
    expect($?.exitstatus).to eq 0
  end

  it "should show version with -v/--version" do
    call "-v --test"
    expect($?.exitstatus).to eq 0
    call "--version --test"
    expect($?.exitstatus).to eq 0
  end

  it "should show formats" do
    call "--show-formats --test"
    expect($?.exitstatus).to eq 0
  end

  it "should grab the right year automatically" do
    year = call "--auto --debug --show-year spec/kevin.pdf"
    expect(year).to eq "2019"
  end

  it "should test real files" do
    call "--auto spec/test.pdf --debug"
    expect($?.exitstatus).to eq 0
  end

  it "should test real files with spaces in their name" do
    call "--auto spec/test\ space.pdf --debug"
    expect($?.exitstatus).to eq 0
  end

  it "should reject non-existent files" do
    call "--auto spec/fake.pdf"
    expect($?.exitstatus).to eq 1
  end
end
