# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "byebug"
require "delfos"
require_relative "support/logging"

require "ostruct"

require_relative "support/timeout" if ENV["TIMEOUT"]

require_relative "support/call_sites"
require_relative "support/neo4j"
require_relative "support/web_mock"
require_relative "support/helper_methods"
require_relative "support/show_class_instance_variables"
require_relative "support/code_climate" if ENV["CI"]

RSpec.configure do |c|
  c.disable_monkey_patching!

  c.expect_with :rspec do |m|
    m.syntax = :expect
  end

  c.example_status_persistence_file_path = ".rspec-failed-examples"

  c.mock_with :rspec do |m|
    m.syntax = :expect
  end

  c.before(:each) do |e|
    Delfos.reset_config!
    puts "before each in spec_helper #{e.inspect} #{Delfos.instance_eval { @config.inspect }}"
    ShowClassInstanceVariables.variables_for(Delfos)
    Delfos.configure { |config| config.logger = DelfosSpecs.logger }
  end

  c.after(:each) do |e|
    Delfos.finish!
    puts "after each in spec_helper #{e.inspect} #{Delfos.instance_eval { @config.inspect }}"

    Delfos.reset_config!
    puts "after each after reset in spec_helper #{e.inspect} #{Delfos.instance_eval { @config.inspect }}"
    ShowClassInstanceVariables.last_executed_rspec_test = e.location
    Delfos.finish!
  end
end
