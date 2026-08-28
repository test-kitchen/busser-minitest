# busser-minitest

[![Gem Version](https://badge.fury.io/rb/busser-minitest.svg)](https://badge.fury.io/rb/busser-minitest)

A [Busser](https://github.com/test-kitchen/busser) runner plugin that runs
[minitest](https://github.com/minitest/minitest) tests as integration tests.

Busser installs minitest on the machine under test during postinstall, then runs
the suite's `minitest` directory against it. Both minitest styles work — classic
`Minitest::Test` subclasses and the `describe`/`it` spec syntax.

## Status

This software project is no longer under active development as it has no active
maintainers. The software may continue to work for some or all use cases, but
issues filed in GitHub will most likely not be triaged. If a new maintainer is
interested in working on this project please come chat with us in #test-kitchen
on Chef Community Slack.

## Requirements

Ruby 3.2 or newer, and busser 0.9.0 or newer. The plugin installs minitest 6.0
or newer on the machine under test.

## Installation

Busser installs the plugin for you when Test Kitchen runs the suite, so there is
usually nothing to do. To install it by hand:

```bash
busser plugin install busser-minitest
```

## Usage

Put your tests in the `minitest` directory of a suite:

```text
test
`-- integration
    |-- default             # suite name
    |   `-- minitest
    |       |-- Gemfile         # optional
    |       `-- test_default.rb
    `-- foo
        `-- minitest
            `-- foo_spec.rb
```

Files are collected recursively, and only names matching `test_*.rb` or
`*_spec.rb` are run — so helpers named anything else are safe to keep alongside.

Classic style:

```ruby
require "minitest/autorun"

class TestFoobar < Minitest::Test
  def test_the_file_was_created
    assert File.exist?("/usr/local/foobar.txt")
  end
end
```

Spec style:

```ruby
require "minitest/autorun"

describe "foobar::default" do
  it "creates foobar.txt" do
    _(File.exist?("/usr/local/foobar.txt")).must_equal true
  end
end
```

### A note on minitest 6

Expectations must be wrapped in `_()`. The bare form —
`File.exist?("...").must_equal true` — was removed in minitest 6 and will raise
`NoMethodError`. `Minitest::Unit::TestCase` was removed back in minitest 5; use
`Minitest::Test`.

### Extra gems

If a `Gemfile` is present in the suite directory, it is `bundle install`ed
before the run, which is how you pull in extra assertion libraries or anything
else your tests need. The install is attempted with `--local` first and falls
back to the network.

## Contributing

Bug reports and pull requests are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md) for how to set up the project, run the test
suite, and format your commits.

## License

Apache License 2.0. See [LICENSE](LICENSE).

Originally created by [Fletcher Nichol](https://github.com/fnichol).
