require "spec_helper"

describe Selector do
  @options = { :auto => true, :test => true }

  it "should generate formats with --format" do
    out = Selector.new()
    forms = out.gen_forms("title", "year", "author")
    expect(forms.instance_of? Array).to eq true
    expect(forms.first.instance_of? String).to eq true
  end

  it "should parse the correct year from content" do
    out = Selector.new("fghdjkfdskj2011fjdkfh")
    out.select_all
    year = out.metadata[:year]
    expect(year.instance_of? String).to eq true
    year_i = year.to_i
    expect(year_i.instance_of? Integer).to eq true
    expect(year_i).to eq 2011
  end
end
