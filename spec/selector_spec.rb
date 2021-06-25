require "spec_helper"

describe Selector do
  it "should generate formats with --format" do
    out = Selector.new()
    forms = out.gen_forms("title", "year", "author")
    expect(forms.instance_of? Array).to eq true
    expect(forms.first.instance_of? String).to eq true
  end
end
