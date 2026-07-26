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
    out = Selector.new("fghdjkfdskj2011fjdkfh", { :format => 0, :auto => true, :no_lookup => true })
    out.select_all
    year = out.metadata[:year]
    expect(year.instance_of? String).to eq true
    year_i = year.to_i
    expect(year_i.instance_of? Integer).to eq true
    expect(year_i).to eq 2011
  end

  describe "Semantic Scholar lookup" do
    let(:match) { { :title => "T", :author => "A", :year => "1999", :venue => nil } }

    it "uses the matched metadata when auto-accepted in --auto mode" do
      fake = double("ScholarLookup", :lookup => match, :source_name => "Test Source")
      out = Selector.new("some content line\nmore text", { :format => 0, :auto => true, :test => true }, fake)
      out.select_all
      expect(out.metadata).to eq(:year => "1999", :title => "T", :author => "A")
    end

    it "falls back to the manual flow when the match is rejected interactively" do
      fake = double("ScholarLookup", :lookup => match, :source_name => "Test Source")
      allow(STDIN).to receive(:gets).and_return("n\n", "0\n", "0\n")
      out = Selector.new("some content line\nmore text", { :format => 0, :auto => false, :test => true }, fake)
      out.select_all
      expect(out.metadata[:title]).not_to eq "T"
    end

    it "falls back to the manual flow when there is no match" do
      fake = double("ScholarLookup", :lookup => nil)
      out = Selector.new("some content line\nmore text", { :format => 0, :auto => true, :test => true }, fake)
      out.select_all
      expect(out.metadata[:title]).not_to eq "T"
    end

    it "never calls the lookup when --no-lookup is set" do
      fake = double("ScholarLookup")
      expect(fake).not_to receive(:lookup)
      out = Selector.new("some content line\nmore text", { :format => 0, :auto => true, :test => true, :no_lookup => true }, fake)
      out.select_all
    end
  end
end
