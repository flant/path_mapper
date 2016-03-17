module PathMapper
  module Node
    module Base
      class FilesIterator
        include Enumerable
        attr_accessor :files

        def initialize(files=[], mapper)
          self.files = files
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
