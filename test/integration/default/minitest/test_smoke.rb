require "minitest/autorun"

# Runs on the machine under test through busser-minitest. Uses the minitest 6
# API the plugin installs: Minitest::Test, and _() around expectations.
class TestSmoke < Minitest::Test
  def test_the_runner_reached_the_machine_under_test
    assert File.directory?(Dir.tmpdir)
  end
end
