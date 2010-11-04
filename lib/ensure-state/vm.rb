require 'ensure-state/vm_backend/base'
require 'ensure-state/errors/vm_backend_errors/vm_not_found_error'

module Virtuoso
module EnsureState
class VM

  # Find a virtual machine instance on the specified backend
  #
  # @params [String] name_or_uuid The name or uuid of the vm to find
  # @params [VMBackend::Base] backend a virtual machine backend implementation,
  #   usage of the abstract implementation is not recommended
  # @return [VM, false] The virtual machine instance, or false if the instance is
  #   is not found
  def self.find name_or_uuid, backend
    begin
      self.find! name_or_uuid, backend
    rescue Errors::VMNotFoundError => e
      false
    end
  end

  # Find a virtual machine instance on the specified backend, raising an exception
  # if the virtual machine is not found
  #
  # @params [String] name_or_uuid The name or uuid of the vm to find
  # @params [VMBackend::Base] backend a virtual machine backend implementation,
  #   usage of the abstract implementation is not recommended
  # @return [VM, false] The virtual machine instance
  # @raise [VMNotFoundError] Exception raised if virtual machine is not found
  def self.find! name_or_uuid, backend
    self.new name_or_uuid, backend
  end

  attr_reader :vm_name, :backend

  def initialize name_or_uuid, backend
    @vm_name = name_or_uuid
    @backend = backend
    verify_backend_is_a_valid_backend @backend
    @vm = retrieve_backend_reference_to_named_vm @backend, @vm_name
  end
  
  # The human readable name of the VM, may be the UUID if there is no human readable
  # name assigned by the backend
  #
  # @return [String] The human readable Virtual Machine name, or uuid if no human readable
  #   name is available
  def name
    name = @backend.vm_name(@vm)
    unless name
      uuid
    end
  end

  # The unique identifier for the VM. Note: The score of the uniqueness is guaranteed by
  # the backend. It may not be universally unique
  #
  # @return [String] The Virtual Machine unique identifier
  def uuid
    @backend.vm_uuid(@vm)
  end
  
  private
  
  def self.verify_backend_is_a_valid_backend backend
    backend.kind_of? VMBackend::Base
  end
  
  def self.retrieve_backend_reference_to_named_vm backend, named_vm
    vm = backend.find named_vm
    unless vm
      raise VMNotFoundError
    end
  end

end
end
end
