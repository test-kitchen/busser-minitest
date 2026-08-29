require "minitest/autorun"

# The other naming convention the plugin accepts, in spec form.
describe "the minitest runner" do
  it "reached the machine under test" do
    _(RUBY_VERSION).must_match(/\A\d+\./)
  end
end
