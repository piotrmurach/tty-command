# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "coveralls"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])

  SimpleCov.start do
    command_name "spec"
    add_filter "spec"
  end
end

require "tty-command"
require "tmpdir"

module TestHelpers
  module Paths
    def gem_root
      ::File.dirname(__dir__)
    end

    def dir_path(*args)
      path = File.join(gem_root, *args)
      FileUtils.mkdir_p(path) unless ::File.exist?(path)
      File.realpath(path)
    end

    def fixtures_path(*args)
      File.expand_path(File.join(dir_path("spec/fixtures"), *args))
    end
  end

  module Platform
    def jruby?
      RUBY_PLATFORM == "java"
    end
  end
end

RSpec.shared_context "sandbox" do
  around(:each) do |example|
    ::Dir.mktmpdir do |dir|
      ::Dir.chdir(dir, &example)
    end
  end
end

RSpec.configure do |config|
  config.include(TestHelpers::Paths)
  config.include(TestHelpers::Platform)
  config.include_context "sandbox", type: :sandbox

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 2

  config.order = :random

  Kernel.srand config.seed
end
