module PathMapper
  module Node
    module Base
      class FilesIterator
        include Enumerable

        def initialize(files=[], mapper)
          @files = files
          @parent_mapper = mapper
        end

        def each
          @files.each do |f|
            yield @parent_mapper.f(f)
          end
        end
      end
    end
  end
end
