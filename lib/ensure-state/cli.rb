require 'ensure-state/cli/option_parser'
require 'ensure-state/engine'

require 'logger'

module Virtuoso
module EnsureState
class CLI

  class << self

    # Creates and starts a new CLI instance for ensure-state.
    # By default reads options from command line ARGV.
    def run!(run_flags=ARGV)
      self.new(run_flags).run!
    end

  end
  
  attr_reader :logger

  def initialize(raw_run_flags)
    @raw_run_flags = raw_run_flags
    @logger = Logger.new(STDOUT)
    
    # defaults
    
    @logger.level = Logger::WARN
    @logger.progname = self.class.name
  end

  # Starts a virtual machine convergence run using the ensure-state system guided by the run_flags passed into the initializer.
  def run!
    cli_parser = parse_run_flags(@raw_run_flags)
    # display any informational messages emitted by the parser
    puts cli_parser.messages.join("\n") unless cli_parser.messages.empty?
    # exit if suggested by parser
    exit(cli_parser.suggested_exit_return_code) if cli_parser.exit_after_message_display_suggested
    
    # setup logger
    logger.level = Logger::DEBUG if cli_parser.options[:debug]
    logger.level = Logger::INFO if cli_parser.options[:verbose]

    # nothing within this application should log at a level higher than fatal
    logger.level = Logger::UNKNOWN if cli_parser.options[:silent]
    
    logger.debug "Completed parsing command line arguments. Starting convergence engine."
    
    display_mode = cli_parser.options[:nogui] ? :vrdp : :gui
    
    # this is where all the actual work happens
    engine = EnsureState::Engine.new(cli_parser.options[:backend], cli_parser.options[:machine], display_mode, cli_parser.options[:ifinstate], @logger)
    
    begin
      engine.converge_vm_state!
    rescue Errors::BackendUnavailableError => e
      logger.fatal "Unable to access backend. Message: (#{e.message})"
      exit(1)
    rescue Errors::StateTransitionError => e
      logger.fatal "Could not transition to state. Message: (#{e.message})"
      exit(1)
    rescue Errors::VMNotFoundError => e
      logger.fatal "Unable to find VM. Message: (#{e.message})"
      exit(1)
    rescue Errors::InvalidVMBackendError => e
      logger.fatal "Unable to find specified VM Backend. Message: (#{e.message})"
      exit(1)
    rescue StandardError => e
      logger.fatal "Fatal Error: #{e.inspect}"
      logger.fatal "Debug Backtrace: \n#{e.backtrace.join("\n")}" if cli_parser.options[:debug]
      exit(1)
    end
    
  end

  private

  def parse_run_flags(run_flags_to_parse)
    CLIOptionParser.new(run_flags_to_parse)
  end

end
end
end
