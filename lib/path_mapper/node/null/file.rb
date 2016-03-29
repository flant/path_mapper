module PathMapper
  module Node
    module Null
      module File
        def create!
          @path.mkpath
          PathMapper.new(@path)
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

        def md5
          nil
        end
      end
    end
  end
end
