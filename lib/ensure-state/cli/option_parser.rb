require 'optparse' #stdlib
require 'ensure-state/version'

module Virtuoso
module EnsureState
class CLIOptionParser

  STATES = [:powered_off, :running, :saved, :paused]
  ACTIONS = [:start, :pause, :stop, :shutdown, :resume]
  BACKENDS = [:virtualbox]

  attr_reader :options
  attr_reader :messages
  attr_reader :exit_after_message_display_suggested
  attr_reader :suggested_exit_return_code

  def initialize(args)
    @messages = Array.new
    @options = Hash.new
    @exit_after_message_display_suggested = false
    @suggested_exit_return_code = 0
    parse!(args)
  end

  private

  def parse!(args)

    # If we have no options, we need to display usage, which is the help option
    args << '-h' if args.empty?

    # The options specified on the command line will be collected in *options*
    # We set defaults here.
    options[:machine] = nil
    options[:ifinstate] = Hash.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: virtuoso-ensure-state [required options] [options]"
      opts.separator "Example: virtuoso-ensure-state -b virtualbox -m development_vm --ifPoweredOff powerUp"
      opts.separator "Version: #{Version.to_s}"

      opts.separator ""
      opts.separator "Required options:"

      # Mandatory arguments
      opts.on('-b', '--backend BACKEND',
        "Backend to use") do |backend|
        options[:backend] = backend.to_sym
      end
      
      opts.on('-m', '--machine MACHINE',
              'Virtual Machine name or UUID this application should manage') do |machine|
        options[:machine] = machine
      end
      
      opts.separator ""
      opts.separator "available BACKENDs: #{BACKENDS.join(', ')}"
      
      opts.separator ""
      opts.separator "Specific options:"

      # Optional arguments
      STATES.each do |state|

        opts.on("--if#{state} ACTION",
                "Action to take if a given virtual machine is in state #{state}") do |action|
          options[:ifinstate][state] = action.to_sym
        end

      end

      opts.separator ""
      opts.separator "Available ACTIONs: #{ACTIONS.join(', ')}"
      opts.separator ""
      opts.separator "Common options:"

      opts.on('-s', "--slient", "Run silently (no output)") do
        options[:silent] = true
      end

      opts.on('-v', "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end

      opts.on('-d', "--debug", "Run with debugging messages and behavior turned on") do
        options[:debug] = true
      end

      # No argument, shows at tail. This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        @messages << opts.to_s
        options[:help_requested] = true
        suggest_exit_after_message_display
      end

      opts.on_tail('-v', '--version', 'Show application version') do
        @messages << Version.to_s
        suggest_exit_after_message_display
      end

    end

    opts.parse!(args)

    ensure_required_switches_passed!

  end

  def ensure_required_switches_passed!
    return if @options[:help_requested]
    
    if @options[:backend].nil? || @options[:machine].nil? then
      @messages << 'Error: Required option not set. Please ensure all required options have been set. See usage by using -h flag.'
      suggest_exit_after_message_display
      suggest_exit_return_code(1)
    end
    
    unless @options[:backend] && BACKENDS.member?(@options[:backend])
      @messages << 'Error: Invalid backend specified. Please ensure backend exists in available backend list. See available backends using -h flag.'
      suggest_exit_after_message_display
      suggest_exit_return_code(1)
    end
    
    unless @options[:ifinstate] && @options[:ifinstate].values.all?{|value|ACTIONS.member?(value)}
      @messages << 'Error: Invalid action specified for :ifinstate. Ensure all actions are set appropriately. See usage and available actions by using the -h flag.'
      suggest_exit_after_message_display
      suggest_exit_return_code(1)
    end
  end

  def suggest_exit_return_code(code)
    @suggested_exit_return_code = code
  end

  def suggest_exit_after_message_display
    @exit_after_message_display_suggested = true
  end

end
end
end
