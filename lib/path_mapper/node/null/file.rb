module PathMapper
  module Node
    module Null
      module File
        def create!
          @path.mkpath
          DirNode.new(@path)
        end

        def delete!(full: false)
          self
        end

        def remove!(content)
          self
        end

        def rename!(new_path)
          PathMapper.new(new_path)
        end
      end
    end
  end
end
