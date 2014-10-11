# -*- encoding: utf-8 -*-
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

require "busser/runner_plugin"

# A Busser runner plugin for Minitest.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
#
class Busser::RunnerPlugin::Minitest < Busser::RunnerPlugin::Base

  postinstall do
    install_gem("minitest", "< 5.0")
    install_gem("bundler")
  end

  def test
    minitest_path = suite_path("minitest")
    runner = File.join(File.dirname(__FILE__), %w[.. minitest runner.rb])

    if File.exist?(File.join(minitest_path, "Gemfile"))
      banner("Gemfile found, bundle installing...")

      # Bundle install local completes quickly if the gems are already found
      # locally it fails if it needs to talk to the internet. The || below is
      # the fallback to the internet-enabled version. It's a speed
      # optimization.
      Dir.chdir(minitest_path) do
        run("PATH=#{ENV["PATH"]}:#{Gem.bindir}; " \
          "bundle install --local || bundle install")
      end
    end

    run_ruby_script!("#{runner} #{minitest_path}")
  end
end
