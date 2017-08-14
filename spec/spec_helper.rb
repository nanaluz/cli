require "bundler/setup"
require "sem"
require "simplecov"
require_relative "support/coverage"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.bundle/"
end

def sem_run(args)
  original_stdout = $stdout
  original_stderr = $stderr

  $stdout = fake_stdout = StringIO.new
  $stderr = fake_stderr = StringIO.new

  Sem::CLI.start(args.split(" "))

  [fake_stdout.string.to_s, fake_stderr.string.to_s]
ensure
  $stdout = original_stdout
  $stderr = original_stderr
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # test coverage percentage only if the whole suite was executed
  unless config.files_to_run.one?
    config.after(:suite) do
      example_group = RSpec.describe("Code coverage")

      example_group.example("must be 100%") do
        coverage = SimpleCov.result
        percentage = coverage.covered_percent

        Support::Coverage.display(coverage)

        expect(percentage).to eq(100)
      end

      # quickfix to resolve weird behaviour in rspec
      raise "coverage is too low" unless example_group.run(RSpec.configuration.reporter)
    end
  end

end