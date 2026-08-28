require_relative "../../spec_helper"

require "fileutils"
require "tmpdir"
require "busser/minitest/test_files"

describe Busser::Minitest::TestFiles do
  def selecting(*names)
    Dir.mktmpdir do |dir|
      names.each do |n|
        path = File.join(dir, n)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "")
      end
      # expand_path, not realpath: on macOS /var is a symlink to /private/var
      # and the module expands rather than resolves, so realpath would not match.
      base = "#{File.expand_path(dir)}/"
      yield Busser::Minitest::TestFiles.in(dir).map { |f| f.delete_prefix(base) }
    end
  end

  it "takes both minitest naming conventions" do
    selecting("test_default.rb", "default_spec.rb") do |found|
      _(found).must_equal %w{default_spec.rb test_default.rb}
    end
  end

  it "searches recursively, so suites can use subdirectories" do
    selecting("a/test_one.rb", "a/b/two_spec.rb") do |found|
      _(found).must_equal %w{a/b/two_spec.rb a/test_one.rb}
    end
  end

  it "leaves helpers and fixtures alone" do
    selecting("spec_helper.rb", "helper.rb", "support/thing.rb", "test_real.rb") do |found|
      _(found).must_equal %w{test_real.rb}
    end
  end

  # test_thing_spec.rb matches both patterns. Globbing them separately and
  # concatenating would hand Rake the same file twice, and minitest would run
  # its tests twice and double the assertion counts.
  it "does not return a file that matches both patterns twice" do
    selecting("test_thing_spec.rb") do |found|
      _(found).must_equal %w{test_thing_spec.rb}
    end
  end

  it "returns a stable order" do
    selecting("test_z.rb", "a_spec.rb", "test_a.rb") do |found|
      _(found).must_equal %w{a_spec.rb test_a.rb test_z.rb}
    end
  end

  it "returns an empty array for a suite with no tests" do
    Dir.mktmpdir { |dir| _(Busser::Minitest::TestFiles.in(dir)).must_equal [] }
  end

  it "ignores non-ruby files that otherwise match" do
    selecting("test_default.sh", "default_spec.txt") { |found| _(found).must_be_empty }
  end
end
