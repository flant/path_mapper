module PathMapper
  module Node
    module Base
      class FilesIterator
        include Enumerable

        attr_accessor :files

        def initialize(files=[])
          self.files = files
        end

        def each
          self.files.each do |f|
            yield PathMapper.new(f)
          end
        end
      end
    end
  end
end
