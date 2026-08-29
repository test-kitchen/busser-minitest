lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "busser/minitest/version"

Gem::Specification.new do |spec|
  spec.name          = "busser-minitest"
  spec.version       = Busser::Minitest::VERSION
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@nichol.ca"]
  spec.description   = "A Busser runner plugin for the minitest testing library"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/test-kitchen/busser-minitest"
  spec.license       = "Apache-2.0"

  spec.required_ruby_version = ">= 3.2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "#{spec.homepage}/blob/main/README.md",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
  }

  # The runner loads rake/testtask on the machine under test, so rake has to
  # be there. It only ever worked because Chef's omnibus Ruby happens to ship
  # rake; an isolated Busser root has whatever is installed into it.
  spec.add_dependency "busser", ">= 0.9.0"
  spec.add_dependency "rake"
end
