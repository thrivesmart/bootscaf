require 'bootscaf'

describe Bootscaf::VERSION do
  it "should have a version" do
    expect(Bootscaf::VERSION).to_not be_nil
  end
end

# describe Bootscaf::CLI do
#   it "should output a version" do
#     expect(subject.command 'version').to output(Bootscaf::VERSION)
#   end
# end