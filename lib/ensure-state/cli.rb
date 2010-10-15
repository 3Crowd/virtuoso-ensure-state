require 'ensure-state/cli/option_parser'

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

  def initialize(raw_run_flags)
    @raw_run_flags = raw_run_flags
  end

  # Starts a virtual machine convergence run using the ensure-state system guided by the run_flags passed into the initializer.
  def run!
    cli_parser = parse_run_flags(@raw_run_flags)
    # display any informational messages emitted by the parser
    puts cli_parser.messages.join("\n") unless cli_parser.messages.empty?
    # exit if suggested by parser
    exit(cli_parser.suggested_exit_return_code) if cli_parser.exit_after_message_display_suggested
  end

  private

  def parse_run_flags(run_flags_to_parse)
    CLIOptionParser.new(run_flags_to_parse)
  end

end
end
end
