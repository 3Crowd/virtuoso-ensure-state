require 'ensure-state/errors/vm_backend_errors/state_transition_error'

module Virtuoso
module EnsureState
module VMBackend

  class Base

    class << self

      # The logger for EnsureState::VMBackend objects
      #
      # @return [Logger] The logger
      def logger
        @@logger
      end

      # Set the logger used for EnsureState::VMBackend objects
      #
      # @param [Logger] logger A logger conforming to the Ruby 1.8+ Logger class interface
      def logger= logger
        @@logger = logger
      end

    end
    
    VALID_ACTION_TO_STATE_APPLICATION_MAP = {
    }

    # Find a virtual machine on the backend
    #
    # @param [String] name_or_uuid the name or uuid to find
    # @return [EnsureState::VM, false] the virtual machine or false if the machine was not found
    def vm_find name_or_uuid
      raise NotImplementedError, "#find is not implemented on the abstract VM Backend, please use a concrete implementation"
    end
    
    # Retrieve the human readable name of the given virtual machine or false if no human readable name
    # is available
    #
    # @param [EnsureState::VM] virtual_machine The virtual machine on which the name should be retrieved
    # @return [String, false] The human readable name of the virtual machine, or false if no human readable name is available
    def vm_name virtual_machine
      raise NotImplementedError, "#vm_name is not implemented on the abstract VM Backend, please use a concrete implementation"
    end
    
    # Retrieve the unique identifier for given virtual machine. This should always be available. The unique
    # identifier (or uuid) is an arbitrary token, chosen by the backend, that uniquely identifies the virtual machine
    # within a scope to be decided by the backend
    #
    # @param [EnsureState::VM] virtual_machine The virtual machine whose uuid should be retrieved
    # @return [String] The unique identifier
    def vm_uuid virtual_machine
      raise NotImplementedError, "#vm_uuid is not implemented on the abstract VM Backend, please use a concrete implementation"
    end
    
    # Retrieve the state of a given virtual machine
    #
    # @param [EnsureState::VM] virtual_machine The virtual machine whose state should be retrieved
    # @return [Symbol] The state of the virtual machine
    def vm_state virtual_machine
      raise NotImplementedError, "#vm_state is not implemented on the abstract VM Backend, please use a concrete implementation"
    end
    
    # Attempt to set the state of a given virtual machine. You must check the return value to ensure the state of of the virtual
    # machine in the backend. To be certain please use vm_set_state! which raises exceptions if the specified state could not
    # be reached
    #
    # @param [Ensure_State::VM] virtual_machine The virtual machine whose state should be set
    # @param [Symbol] state The state to which the machine should be moved
    # @return [Boolean] True if machine has successfully been moved to the specified state, False if not
    def vm_set_state virtual_machine, state
      begin
        vm_set_state! virtual_machine, state
      rescue Errors::StateTransitionError => e
        return false
      end
      true
    end
    
    # Set the state of a given virtual machine. If the state cannot be reached from the current state or a failure occurs in setting
    # an exception is raised, depending on the specific error. The exception thrown will always subclass Errors::StateTransitionError
    #
    # @param [Ensure_State::VM] virtual_machine The virtual machine whose state will be set
    # @param [Symbol] state The state to which the machine will be moved
    # @raise [Errors::StateTransitionError] An exception, or a subclass thereof, which is raised when the specified state could not be reached.
    #   The reason for which is specified by the particular subclass of StateTransitionError
    def vm_set_state! virtual_machine, state
      riase NotImplementedError, "#vm_set_state! is not implemented on the abstract VM Backend, please use a concrete implementation"
    end

  end

end
end
end