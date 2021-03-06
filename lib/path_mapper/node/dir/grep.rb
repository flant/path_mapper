module PathMapper
  module Node
    module Dir
      module Grep
        def grep(reg, recursive: false, path: @path, exclude: [], **kwargs)
          exclude.map! {|str_or_reg| Regexp.new(str_or_reg) }
          path_ = "#{path}#{'/**' if recursive}/*"
          files = ::Dir[path_].select {|f| f =~ reg and !exclude.any? {|reg_| f =~ reg_ } }
          files.map! {|f| Pathname.new(f) }
          FilesIterator.new(files, self)
        end

        def grep_dirs(recursive: false, exclude: [], **kwargs)
          exclude.map! {|str_or_reg| Regexp.new(str_or_reg) }
          self.grep(/.*/, recursive: recursive, **kwargs).select {|n| !exclude.any? {|reg_| n.name =~ reg_ } if n.dir? }
        end

        def grep_files(recursive: false, exclude: [], **kwargs)
          exclude.map! {|str_or_reg| Regexp.new(str_or_reg) }
          self.grep(/.*/, recursive: recursive, **kwargs).select {|n| !exclude.any? {|reg_| n.name =~ reg_ } if n.file? }
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
