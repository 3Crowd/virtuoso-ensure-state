#Ensure the ensure-state library directory is on the include path
include_path_location = File.join(File.dirname(__FILE__),'ensure-state')
$:.push(include_path_location) unless $:.include?(include_path_location)
