module PathMapper
  module Patch
    module Pathname
      module Mixin
        def to_pathmapper
          PathMapper.new(self)
        end
      end
    end
  end
end

::Pathname.send(:include, PathMapper::Patch::Pathname::Mixin)