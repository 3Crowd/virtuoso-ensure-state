require 'ensure-state/errors/vm_backend_errors/backend_unavailable_error'

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
      raise NotImplementedError, "#find is not implemented"
    end
    
    def vm_name virtual_machine
      raise NotImplementedError, "#vm_name is not implemented"
    end
    
    def vm_uuid virtual_machine
      raise NotImplementedError, "#vm_uuid is not implemented"
    end
    
    def vm_state virtual_machine
      raise NotImplementedError, "#vm_state is not implemented"
    end
    
    def vm_set_state! virtual_machine, state
      raise NotImplementedError, "#vm_set_state! is not implemented"
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