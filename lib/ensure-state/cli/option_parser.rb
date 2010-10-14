require 'optparse' #stdlib
require 'ensure-state/version'

module Virtuoso
module EnsureState
class CLIOptionParser

  STATES = %w[PoweredOff Saved Teleported Aborted Running Paused Stuck Teleporting LiveSnapshotting Starting Stopping Saving Restoring TeleportingPausedVM TeleportingIn DeletingSnapshotOnline DeletingSnapshotPaused RestoringSnapshot DeletingSnapshot SettingUp]
  ACTIONS = %w[powerUp powerUpPaused reset pause resume powerButton sleepButton saveState]

  attr_reader :options
  attr_reader :messages

  def initialize(args)
    @messages = Array.new
    @options = Hash.new
    parse!(args)
  end

  private

  def parse!(args)

    # The options specified on the command line will be collected in *options*
    # We set defaults here.
    options[:ifinstate] = Hash.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: virtuoso-ensure-state [options]"
      opts.separator "Version: #{Version.to_s}"

      opts.separator ""
      opts.separator "Required options:"

      # Mandatory arguments
      opts.on('-m', '--machines x,y,z', Array,
              'Virtual Machine names or UUIDs this application should manage') do |machines|
        options.config_file << config
      end

      opts.separator ""
      opts.separator "Specific options:"

      # Optional arguments
      STATES.each do |state|

        opts.on("--if#{state} [ACTION]", ACTIONS,
                "Action to take if a given virtual machine is in state #{state}") do |action|
          options[:ifinstate][state] = action
        end

      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail. This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        @messages << opts.to_s
      end

      opts.on_tail('-v', '--version', 'Show application version') do
        @messages << Version.to_s
      end

    end

    opts.parse!(args)

  end

end
end
end
