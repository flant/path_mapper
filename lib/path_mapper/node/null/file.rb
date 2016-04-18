module PathMapper
  module Node
    module Null
      module File
        def _create!
          self.with_dry_run do |dry_run|
            if dry_run
              self.storage_tree(@path)
            else
              @path.mkpath
            end
          end
          { d: { result: self._create_node(@path) }, code: :created }
        end

        def _put!(content)
          { d: { result: self._file_puts(content), diff: self.custom_diff(nil, with_line_separator(content)) }, code: :created }
        end

        def safe_put!(content)
          { d: { result: self.put!(content, logger: false), diff: self.custom_diff(nil, with_line_separator(content)) }, code: :created }
        end

        def _append_line!(line)
          { d: { result: self.put!(line, logger: false), diff: self.custom_diff(nil, with_line_separator(line)) }, code: :created }
        end

        def _delete!(full: false)
          { d: { result: self }, code: :ok }
        end

        def _remove!(content)
          { d: { result: self }, code: :ok }
        end

        def _rename!(new_path)
          { d: { result: self._create_node(new_path) }, code: :ok }
        end

        def md5
          nil
        end
      end
    end
  end
end
