require "spec_helper"

describe ScholarLookup do
  let(:lookup) { ScholarLookup.new }
  let(:url) { %r{https://api\.semanticscholar\.org/graph/v1/paper/search} }

  it "returns a match when the API finds a paper" do
    stub_request(:get, url).to_return(:status => 200, :body => {
      :data => [{
        :title => "A Great Paper",
        :year => 2020,
        :authors => [{ :name => "Jane Smith" }, { :name => "Bob Jones" }],
      }],
    }.to_json)

    result = lookup.lookup("A Great Paper")
    expect(result).to eq(:title => "A Great Paper", :author => "Smith Jones", :year => "2020", :venue => nil)
  end

  it "returns nil when there are no results" do
    stub_request(:get, url).to_return(:status => 200, :body => { :data => [] }.to_json)
    expect(lookup.lookup("nonsense query")).to be_nil
  end

  it "returns nil on timeout" do
    stub_request(:get, url).to_timeout
    expect(lookup.lookup("some title")).to be_nil
  end

  it "returns nil on a non-200 response" do
    stub_request(:get, url).to_return(:status => 503)
    expect(lookup.lookup("some title")).to be_nil
  end

  it "returns nil on malformed JSON" do
    stub_request(:get, url).to_return(:status => 200, :body => "not json{")
    expect(lookup.lookup("some title")).to be_nil
  end

  it "returns nil when the paper is missing title/authors" do
    stub_request(:get, url).to_return(:status => 200, :body => { :data => [{ :year => 2020 }] }.to_json)
    expect(lookup.lookup("some title")).to be_nil
  end

  it "does not make a request for a blank/too-short query" do
    expect(lookup.lookup("")).to be_nil
    expect(lookup.lookup(nil)).to be_nil
    expect(a_request(:get, url)).not_to have_been_made
  end
end
