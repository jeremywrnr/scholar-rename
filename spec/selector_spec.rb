# rspec unit testing for modname

require "spec_helper"

describe SR do
  before "mute program help output" do
    $muted = true
  end

  it "should show standard help when given no args" do
    expect("nil").to eq nil
  end
end

