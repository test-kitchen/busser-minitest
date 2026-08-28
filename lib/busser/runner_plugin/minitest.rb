#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rbconfig" unless defined?(RbConfig)
require "shellwords" unless defined?(Shellwords)

require "busser/runner_plugin"

# A Busser runner plugin for Minitest.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
#
class Busser::RunnerPlugin::Minitest < Busser::RunnerPlugin::Base

  # Installs minitest and bundler onto the machine under test. Runs once, when
  # Busser installs this plugin.
  postinstall do
    install_gem("minitest", ">= 6.0")
    install_gem("bundler")
  end

  # Runs the suite's tests.
  #
  # If the suite ships a Gemfile its gems are installed first, so a suite can
  # pull in extra assertion libraries. The install is tried with --local before
  # falling back to the network, which keeps repeat runs off the internet.
  #
  # @return [void]
  def test
    minitest_path = suite_path("minitest")
    runner = File.join(File.dirname(__FILE__), %w{.. minitest runner.rb})

    if File.exist?(File.join(minitest_path, "Gemfile"))
      banner("Gemfile found, bundle installing...")
      Dir.chdir(minitest_path) do
        run(self.class.bundle_install_command(File.join(minitest_path, "Gemfile")))
      end
    end

    run_ruby_script!(self.class.runner_command(runner, minitest_path))
  end

  # Builds the bundle install command for a suite's own Gemfile.
  #
  # bundler is invoked through the Ruby that is running Busser rather than
  # whatever `bundle` happens to be on PATH. On a machine with more than one
  # Ruby those differ, and the wrong one installs the suite's gems where the
  # runner will not find them. The sibling plugins already do it this way.
  #
  # The --local attempt is a speed optimisation: it finishes immediately when
  # the gems are already present and fails when it would need the network, so
  # the second attempt is the fallback.
  #
  # @param gemfile [String, Pathname] path to the suite's Gemfile
  # @return [String] the command to run
  def self.bundle_install_command(gemfile)
    bundle = [
      Shellwords.escape(File.join(RbConfig::CONFIG["bindir"], "ruby")),
      Shellwords.escape(File.join(Gem.bindir, "bundle")),
      "install", "--gemfile", Shellwords.escape(gemfile.to_s)
    ].join(" ")

    "#{bundle} --local || #{bundle}"
  end

  # Builds the command that runs the suite.
  #
  # Both paths are quoted: the suite path is rooted at BUSSER_ROOT, which the
  # caller chooses, so an unquoted path containing a space would be split by
  # the shell.
  #
  # @param runner [String, Pathname] path to the runner script
  # @param suite [String, Pathname] the suite directory holding the tests
  # @return [String] the command to run
  def self.runner_command(runner, suite)
    "#{Shellwords.escape(runner.to_s)} #{Shellwords.escape(suite.to_s)}"
  end
end
