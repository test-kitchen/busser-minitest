require_relative "../../spec_helper"

require "rbconfig"
require "shellwords"
require "busser/runner_plugin/minitest"

describe Busser::RunnerPlugin::Minitest do
  describe ".runner_command" do
    it "runs the runner against the suite" do
      cmd = Busser::RunnerPlugin::Minitest.runner_command("/gems/runner.rb",
        "/opt/busser/suites/minitest")

      _(Shellwords.split(cmd)).must_equal ["/gems/runner.rb", "/opt/busser/suites/minitest"]
    end

    it "quotes a suite path containing spaces" do
      cmd = Busser::RunnerPlugin::Minitest.runner_command("/a/runner.rb",
        "/tmp/my tests/minitest")

      _(Shellwords.split(cmd)).must_equal ["/a/runner.rb", "/tmp/my tests/minitest"]
    end

    it "accepts Pathname arguments" do
      cmd = Busser::RunnerPlugin::Minitest.runner_command(Pathname.new("/a/r.rb"),
        Pathname.new("/b/minitest"))

      _(Shellwords.split(cmd)).must_equal ["/a/r.rb", "/b/minitest"]
    end
  end

  describe ".bundle_install_command" do
    let(:cmd) { Busser::RunnerPlugin::Minitest.bundle_install_command("/suite/Gemfile") }

    # The regression this guards. Calling bare `bundle` used whatever was first
    # on PATH, which on a machine with more than one Ruby is not necessarily the
    # Ruby running the tests -- so the suite's gems landed somewhere the runner
    # could not see them.
    it "invokes bundler through the running Ruby rather than PATH" do
      first, second = Shellwords.split(cmd).first(2)

      _(first).must_equal File.join(RbConfig::CONFIG["bindir"], "ruby")
      _(second).must_equal File.join(Gem.bindir, "bundle")
    end

    it "names the suite's Gemfile explicitly" do
      _(Shellwords.split(cmd)).must_include "--gemfile"
      _(Shellwords.split(cmd)).must_include "/suite/Gemfile"
    end

    # --local finishes immediately when the gems are already present and fails
    # when it would need the network, so the plain attempt is the fallback.
    it "falls back from the local attempt to a networked one" do
      _(cmd).must_include "--local || "
      _(cmd.scan("--gemfile").length).must_equal 2
    end

    it "quotes a Gemfile path containing spaces" do
      cmd = Busser::RunnerPlugin::Minitest.bundle_install_command("/tmp/my tests/Gemfile")

      _(Shellwords.split(cmd.split(" || ").first)).must_include "/tmp/my tests/Gemfile"
    end
  end
end
