require 'bootscaf'

describe Bootscaf::VERSION do
  it "should have a version" do
    expect(Bootscaf::VERSION).to_not be_nil
  end
end