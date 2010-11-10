require 'ensure-state/errors/vm_backend_errors/backend_unavailable_error'
require 'ensure-state/errors/vm_backend_errors/invalid_state_error'

require 'ensure-state/vm_backend/base'

require 'rubygems'
require 'virtualbox'

module Virtuoso
module EnsureState
module VMBackend

  class VirtualBox < Base
    
    VALID_ACTION_TO_STATE_APPLICATION_MAP = {
      :start => [:powered_off, :saved],
      :pause => [:running],
      :saved_state => [:running],
      :stop => [:running],
      :shutdown => [:running],
      :resume => [:paused]
    }
    
    def initialize
      @backend = VirtualBox
      ensure_valid_backend_version @backend
    end

    def vm_find name_or_uuid
      @backend.find(name_or_uuid)
    end
    
    def vm_name virtual_machine
      virtual_machine.name
    end
    
    def vm_uuid virtual_machine
      virtual_machine.uuid
    end
    
    def vm_state virtual_machine
      virtual_machine.state
    end
    
    def vm_set_state! virtual_machine, state_to_set, options
      ensure_transition_action_valid!(virtual_machine.state, state_to_set)
      state_set_successfully = case state_to_set
        when :start then
          virtual_machine.start(options)
        when :pause then
          virtual_machine.pause
        when :saved_state then
          virtual_machine.save_state
        when :stop then
          virtual_machine.stop
        when :shutdown then
          virtual_machine.shutdown
        when :resume then
          virtual_machine.resume
      end
      raise Errors::StateTransitionError, "Error transitioning VM to state #{state_to_set}. Virtual Machine backend thinks machine is now in state: #{virtual_machine.state}" unless state_set_successfully
    end
    
    def can_transition_to_state? current_state, action
      action_set = VALID_ACTION_TO_STATE_APPLICATION_MAP[action]
      !action_set.nil? && action_set.member?(current_state)
    end
    
    private
    
    def ensure_transition_action_valid! current_state, action
      message = VALID_ACTION_TO_STATE_APPLICATION_MAP[action].nil? ? "Setting state to #{action} not implemented" : "Machine not in one of (#{VALID_ACTION_TO_STATE_APPLICATION_MAP[action] }) states. Cannot #{action}"
      raise Errors::InvalidStateError, message unless can_transition_to_state? current_state, action
    end
    
    def ensure_valid_backend_version backend
      if backend.version.nil?
        raise Errors::BackendUnavailableError
      end
    end
    
  end

end
end
end