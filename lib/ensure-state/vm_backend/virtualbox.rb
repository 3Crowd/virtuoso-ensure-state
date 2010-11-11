require 'ensure-state/errors/vm_backend_errors/backend_unavailable_error'
require 'ensure-state/errors/vm_backend_errors/invalid_state_error'
require 'ensure-state/errors/vm_backend_errors/vm_not_found_error'

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
    
    VM_BACKEND_SETTLE_TIME = 0.5 #seconds
    
    attr_reader :logger
    
    def initialize(logger = Logger.new(STDOUT))
      @logger = logger.dup
      @logger.progname = self.class.name
      
      logger.debug("Initializing VirtualBox Backend")
      
      @backend = ::VirtualBox
      ensure_valid_backend_version @backend
    end

    def vm_find name_or_uuid
      logger.debug("Finding VM (#{name_or_uuid})")
      vm = @backend::VM.find(name_or_uuid)
      logger.debug("Found VM (#{name_or_uuid})") if vm
      vm
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
    
    def vm_set_state! virtual_machine, state_to_set, options = {}
      ensure_transition_action_valid!(virtual_machine.state, state_to_set)
      options[:mode] = :gui if state_to_set == :start && options[:mode].nil?
      state_set_successfully = case state_to_set
        when :start then
          logger.debug("Backend starting VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.start(options[:mode])
        when :pause then
          logger.debug("Backend pausing VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.pause
          #FIXME: evil hack, this method doesn't seem to block until completed
          sleep(VM_BACKEND_SETTLE_TIME)
          virtual_machine.paused?
        when :saved_state then
          logger.debug("Backend saving state of VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.save_state
        when :stop then
          logger.debug("Backend stopping VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.stop
          #FIXME: evil hack, this method doesn't seem to block until completed
          sleep(VM_BACKEND_SETTLE_TIME)
          virtual_machine.powered_off?
        when :shutdown then
          logger.debug("Backend shutting down VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.shutdown
          #FIXME: this command should not fail, but the guest operating system won't neccessarily shut down immediately. this is a safe shutdown
          true
        when :resume then
          logger.debug("Backend resuming VM (#{virtual_machine.uuid}/#{virtual_machine.name})")
          virtual_machine.resume
          #FIXME: evil hack, this method doesn't seem to block until completed
          sleep(VM_BACKEND_SETTLE_TIME)
          virtual_machine.running?
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
      version = backend.version
      logger.debug("VirtualBox backend version: #{version}")
      raise Errors::BackendUnavailableError, "Backend could not be loaded" if version.nil?
      true
    end
    
  end

end
end
end