require_relative '../test_helper'
require 'mocha/setup'

class CommandLineConfigurationTest < Test::Unit::TestCase
  include Bane

  # Creation tests (uses a cluster of objects starting at the top-level CommandLineConfiguration)

  def test_creates_specified_makeable_on_given_port
    services = process arguments: [3000, 'ThingA'],
                       configuration: { 'ThingA' => SimpleMaker.new('ThingA'),
                                        'ThingB' => SimpleMaker.new('ThingB') }
    assert_equal 1, services.size, "Wrong number of services, got #{services}"
    assert_makeable_created(services.first, port: 3000, name: 'ThingA')
  end

  def test_creates_multiple_makeables_on_increasing_ports
    services = process arguments: [4000, 'ThingA', 'ThingB'],
                       configuration: {'ThingA' => SimpleMaker.new('ThingA'),
                                       'ThingB' => SimpleMaker.new('ThingB') }

    assert_equal 2, services.size, "Wrong number of services, got #{services}"
    assert_makeable_created(services.first, port: 4000, name: 'ThingA')
    assert_makeable_created(services.last, port: 4000 + 1, name: 'ThingB')
  end

  def test_creates_all_known_makeables_in_alphabetical_order_if_only_port_specified
    services = process arguments: [4000],
                       configuration: { 'ThingB' => SimpleMaker.new('ThingB'),
                                        'ThingC' => SimpleMaker.new('ThingC'),
                                        'ThingA' => SimpleMaker.new('ThingA') }

    assert_equal 3, services.size, "Wrong number of services created, got #{services}"
    assert_equal 'ThingA', services[0].name
    assert_equal 'ThingB', services[1].name
    assert_equal 'ThingC', services[2].name
  end

  def process(options)
    arguments = options.fetch(:arguments)
    makeables = options.fetch(:configuration)
    CommandLineConfiguration.new(makeables).process(arguments) { |errors| raise errors }
  end

  def assert_makeable_created(services, parameters)
    assert_equal parameters.fetch(:port), services.port
    assert_equal parameters.fetch(:name), services.name
  end

  class SimpleMaker
    attr_reader :name, :port, :host
    def initialize(name)
      @name = name
    end

    def make(port, host)
      @port = port
      @host = host
      self
    end
  end

  # Failure tests (uses a cluster of objects starting at the top-level CommandLineConfiguration)

  def test_unknown_service_fails_with_message
    assert_invalid_arguments_fail_matching_message([IRRELEVANT_PORT, 'AnUnknownService'], /Unknown Service/i)
  end

  def test_invalid_option_fails_with_error_message
    assert_invalid_arguments_fail_matching_message(['--unknown-option', IRRELEVANT_PORT], /Invalid Option/i)
  end

  def assert_invalid_arguments_fail_matching_message(arguments, message_matcher)
    block_called = false
    CommandLineConfiguration.new({}).process(arguments) do |error_message|
      block_called = true
      assert_match message_matcher, error_message
    end
    assert block_called, "Expected invalid arguments to invoke the failure block"
  end

end
