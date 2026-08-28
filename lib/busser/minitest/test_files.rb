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

module Busser
  module Minitest
    # Selects the test files to run out of a suite directory.
    #
    # This lives apart from runner.rb because that file is a script: requiring
    # it invokes a Rake task. Keeping the selection rule here lets it be tested
    # without running anything.
    module TestFiles
      # Patterns a file must match to be treated as a test, relative to the
      # suite directory. Both minitest naming conventions are honoured, and the
      # search is recursive so suites can group tests into subdirectories.
      PATTERNS = ["**/*_spec.rb", "**/test_*.rb"].freeze

      module_function

      # @param base_path [String, Pathname] the suite directory to search
      # @return [Array<String>] matching test files, sorted and de-duplicated
      #   so a file matching both patterns is not run twice
      def in(base_path)
        base = File.expand_path(base_path.to_s)
        PATTERNS.flat_map { |pattern| Dir.glob(File.join(base, pattern)) }.uniq.sort
      end
    end
  end
end
