module PathMapper
  module Node
    module Dir
      module Grep
        def grep(reg, recursive: false, path: @path, **kwargs)
          path_ = "#{path}#{'/**' if recursive}/*"
          files = ::Dir[path_].select {|f| f =~ reg }
          files.map! {|f| Pathname.new(f) }
          FilesIterator.new(files, self)
        end

        def grep_dirs(recursive: false, **kwargs)
          self.grep(/.*/, recursive: recursive, **kwargs).select {|n| n.dir? }
        end

        def grep_files(recursive: false, **kwargs)
          self.grep(/.*/, recursive: recursive, **kwargs).select {|n| n.file? }
        end

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
end
