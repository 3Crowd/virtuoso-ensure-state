require 'lib/ensure-state/version'

Gem::Specification.new do |s|
  s.name	= "virtuoso-ensure-state"
  s.version	= Virtuoso::EnsureState::Version
  s.platform	= Gem::Platform::RUBY
  s.authors	= ["3Crowd Technologies, Inc.", "Justin Lynn"]
  s.email	= ["eng@3crowd.com"]
  s.homepage	= "http://github.com/3Crowd/virtuoso-ensure-state"
  s.summary	= "Ensures the state of virtual machines on the host system"
  s.description = "Ensures the state of virtual machines on the host system. If a Virtual Machine is not in the desired state, report it, and, if desired, take action to put them in that state"

  s.add_dependency('virtualbox', '>=0.7.5')
  s.required_rubygems_version	= ">= 1.3.6"

  s.files	= Dir.glob("{bin,lib}/**/*") + %w(LICENSE README CHANGELOG)
  s.executables	= ['virtuoso-ensure-state']
  s.require_paths = ['lib']
end
