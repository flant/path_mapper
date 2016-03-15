module PathMapper
  module Node
    module Base
      class FilesIterator
        include Enumerable

        def initialize(files)
          @files = files
        end

        def each
          @files.each do |f|
            yield PathMapper.new(f)
          end
        end
      end
    end
  end
end
