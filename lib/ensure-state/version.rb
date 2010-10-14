module Virtuoso
module EnsureState
class Version

  MAJOR = '0'
  MINOR = '0'
  POINT = '1'
  RELEASE_MARKER = 'beta'

  def self.to_s
    [MAJOR,MINOR,POINT,RELEASE_MARKER].join('.')
  end

end
end
end
