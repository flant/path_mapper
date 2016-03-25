module PathMapper
  module Node
    module Base
      module Grep
        def grep(reg, recursive: false, path: @path, **kwargs)
          []
        end

        def grep_dirs(recursive: false, **kwargs)
          []
        end

        def grep_files(recursive: false, **kwargs)
          []
        end
      end
    end
  end
end
