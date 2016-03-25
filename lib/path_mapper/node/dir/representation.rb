module PathMapper
  module Node
    module Dir
      module Representation
        def empty?
          @path.children.empty?
        end
      end
    end
  end
end