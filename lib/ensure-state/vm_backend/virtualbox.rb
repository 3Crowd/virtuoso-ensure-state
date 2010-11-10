require 'ensure-state/errors/vm_backend_errors/backend_unavailable_error'
require 'ensure-state/errors/vm_backend_errors/invalid_state_error'

require 'rubygems'
require 'virtualbox'

module Virtuoso
module EnsureState
module VMBackend

  class VirtualBox < Base
    
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
      case state_to_set
        when :start then
          raise Errors::InvalidStateError, "Machine not powered_off. Cannot start" unless virtual_machine.state == :powered_off || virtual_machine.state == :saved
          unless virtual_machine.start(options)
            raise Errors::StateTransitionError
          end
        when :pause then
          raise Errors::InvalidStateError, "Machine not running. Cannot pause" unless virtual_machine.state == :running
          unless virtual_machine.pause
            raise Errors::StateTransitionError
          end
        when :saved_state then
          raise Errors::InvalidStateError, "Machine not running. Cannot save state" unless virtual_machine.state == :running
          unless virtual_machine.save_state
            raise Errors::StateTransitionError
          end
        when :stop then
          raise Errors::InvalidStateError, "Machine not running. Cannot stop" unless virtual_machine.state == :running
          unless virtual_machine.stop
            raise Errors::StateTransitionError
          end
        when :shutdown then
          raise Errors::InvalidStateError, "Machine not running. Cannot shutdown" unless virtual_machine.state == :running
          unless virtual_machine.shutdown
            raise Errors::StateTransitionError
          end
        when :resume then
          raise Errors::InvalidStateError, "Machine not paused, cannot resume" unless virtual_machine.state == :paused
          unless virtual_machine.resume
            raise Errors::StateTransitionError
          end
        else
          raise Errors::InvalidStateError, "Setting state to #{state_to_set} not implemented"
      end
    end
    
    private
    
    def ensure_valid_backend_version backend
      if backend.version.nil?
        raise Errors::BackendUnavailableError
      end
    end
    
  end

end
end
end