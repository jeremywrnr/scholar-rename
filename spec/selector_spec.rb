require 'spec_helper'

describe Selector do
  it 'should generate formats with --format' do
    out = Selector.new("pdf content here", {format: 0})
    forms = out.gen_forms('title', 'year', 'author')
    expect(forms.instance_of? Array).to eq true
  end
end
