require 'ensure-state/vm_backend/virtualbox'

require 'ensure-state/vm'

require 'ensure-state/errors/invalid_vm_backend_error'

module Virtuoso
module EnsureState

  class Engine

    attr_reader :state_and_action_map, :logger

    # Instantiate a new engine for converging vm state
    #
    # @param [EnsureState::VMBackend::Base] backend The VM Backend where the machine specified in vm_name can be found
    # @param [String] vm_name A name or UUID which uniquely identifies the virtual machine inside the backend specified in backend
    # @param [Hash<Symbol, Symbol>] state_and_action_map A mapping of states, if a VM is in one of those keyed states, take the specified action. Otherwise, do nothing
    # @param [Logger] logger The logger for engine information
    def initialize backend, vm_name, vm_display_mode, state_and_action_map, logger = Logger.new(STDOUT)
      @backend_name = backend
      @vm_display_mode = vm_display_mode
      @vm_name = vm_name
      @state_and_action_map = state_and_action_map
      @logger = logger.dup
      @logger.progname = self.class.name
    end

    # Converges the specified backend VM state utilizing the state_and_action_map
    #
    # @raise [Errors::BackendUnavailableError] The specified backend was unavailable for interaction
    # @raise [Errors::StateTransitionError] There was an error transitioning a VirtualMachine into a specified state
    # @raise [Errors::VMNotFoundError] The VM specified as not found by the backend
    # @raise [Errors::InvalidVMBackendError] The specified VM Backend was not registered
    def converge_vm_state!
      logger.debug "Converging VM State"
      action_to_take = state_and_action_map[vm.state]
      if action_to_take.nil?
        logger.info "No action specified for current virtual machine state (#{vm.state})"
      else
        logger.info "Taking action: #{action_to_take}"
        vm.state = action_to_take if backend.can_transition_to_state?(vm.state, action_to_take)
      end
    end

    # The backend in which the specified virtual machine should be found
    #
    # @raise [Errors::InvalidVMBackendError] The specified VM Backend was not registered
    def backend
      @backend ||= load_backend(@backend_name)
    end

    # The virtual machine to be operated on by this engine
    #
    # @raise [Errors::VMNotFoundError] The VM specified was not found by the backend
    def vm
      logger.debug("Finding VM (#{@vm_name})")
      return @vm if @vm
      @vm = VM.find!(@vm_name, backend, logger)
      @vm.display_mode = @vm_display_mode
      @vm
    end

    private
    
    def load_backend(backend)
      logger.debug "Finding backend for load call: #{backend}"
      backend_instance = case backend
        when :virtualbox
          VMBackend::VirtualBox.new(logger)
        else
          raise Errors::InvalidVMBackendError, "Specified backend (#{backend}) is not a registered backend"
      end
      logger.debug "Found backend for load call: #{backend}"
      return backend_instance
    end

  end

end
end