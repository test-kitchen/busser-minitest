Feature: Test command
  In order to run tests written with minitest
  As a user of Busser
  I want my tests to run when the minitest runner plugin is installed

  Background:
    Given a test BUSSER_ROOT directory named "busser-minitest-test"
    And a sandboxed GEM_HOME directory named "busser-minitest-gem-home"
    When I successfully run `busser plugin install busser-minitest --force-postinstall`
    Given a suite directory named "minitest"

  Scenario: A passing test suite
    Given a file in suite "minitest" named "test_passing.rb" with:
    """
    require 'minitest/autorun'

    class TestAllTheThings < MiniTest::Unit::TestCase
      def setup
        @answer = "you know"
      end

      def test_that_the_answer_is_correct
        assert_equal "you know", @answer
      end
    end
    """
    Given a file in suite "minitest" named "passing_spec.rb" with:
    """
    require 'minitest/autorun'

    describe 'Winning' do
      before do
        @winning = true
      end

      it "wins, naturally" do
        @winning.must_equal true
      end
    end
    """
    When I run `busser test minitest`
    Then the output should contain:
    """
    2 tests, 2 assertions, 0 failures, 0 errors, 0 skips
    """
    And the exit status should be 0

  Scenario: A failing test suite
    Given a file in suite "minitest" named "failing_spec.rb" with:
    """
    require 'minitest/autorun'

    Twitter = Struct.new(:online)

    describe 'Fail whale' do
      let(:twitter) { Twitter.new(false) }

      it "never goes down" do
        twitter.online.must_equal true
      end
    end
    """
    When I run `busser test minitest`
    Then the output should contain "Expected: true"
    Then the output should contain "Actual: false"
    And the exit status should not be 0
