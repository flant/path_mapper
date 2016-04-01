module PathMapper
  module Node
    module File
      module File
        def _put!(content)
          context = self.value
          { d: { result: self._file_puts(content), diff: self.diff(context) }, code: :modified }
        end

        def _remove_line!(line)
          lines = self.lines.select {|l| l !~ Regexp.new(line) and l }
          if lines.empty?
            self._delete!
          else
            context = self.value
            { d: { result: self._file_puts(lines), diff: self.diff(context) }, code: :modified }
          end
        end

        def _delete!(full: false)
          context = self.value

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
          { d: { result: PathMapper.new(@path), diff: Diffy::Diff.new(with_line_separator(context), nil).to_s }, code: :deleted }
        end

        def check(line)
          self.lines.any? { |l| l =~ Regexp.new(line) }
        end
      end
    end
  end
end
