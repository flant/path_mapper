module PathMapper
  module Node
    module File
      module File
        def _put!(content)
          if self.compare_with(content)
            { d: { result: self }, code: :ok }
          else
            old_value = self.raw_value
            { d: { result: self._file_puts(content), diff: self.diff(old_value) }, code: :modified }
          end
        end

        def _append_line!(line)
          if self.check(line)
            { d: { result: self }, code: :ok }
          else
            old_value = self.raw_value
            { d: { result: self._file_puts(line, 'a+'), diff: self.diff(old_value) }, code: :modified }
          end
        end

        def _remove_line!(line)
          if self.check(line)
            lines = self.lines.select {|l| l !~ Regexp.new(line) and l }
            old_value = self.raw_value
            if lines.empty?
              { d: { result: self.delete!(logger: false), diff: self.custom_diff(old_value, nil) }, code: :deleted }
            else
              { d: { result: self._file_puts(lines), diff: self.diff(old_value) }, code: :modified }
            end
          else
            { d: { result: self }, code: :ok }
          end
        end

        def _delete!(full: false)
          old_value = self.raw_value

          self.with_dry_run do |dry_run|
            if dry_run
              self.delete_storage_branch(@path)
            else
              @path.delete
            end
          end

          if full and (dir_node = self.parent).empty?
            dir_node.delete!(full: full)
          end
          { d: { result: PathMapper.new(@path), diff: self.custom_diff(old_value, nil) }, code: :deleted }
        end

        def check(line)
          self.lines.any? { |l| l =~ Regexp.new(line) }
        end
      end
    end
  end
end
