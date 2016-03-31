module PathMapper
  module Node
    module Base
      module File
        def method_missing(m, *args, &block)
          self.send("_#{m}", *args, &block)[:d][:result] if self.respond_to?("_#{m}")
        end

        def _create!
          { d: { result: self }, code: :ok }
        end

        def _put!(content)
          { d: { result: self._file_puts(content), diff: self.diff(nil) }, code: :created }
        end

        def _safe_put!(content)
          if self.file?
            { d: { result: self }, code: :ok }
          else
            self._put!(content)
          end
        end

        def _append!(content)
          context = self.value
          { d: { result: self._file_puts(content, 'a+'), diff: self.diff(context) }, code: :modified }
        end

        def _safe_append!(content)
          if self.check(content)
            { d: { result: self }, code: :ok }
          else
            self._append!(content)
          end
        end

        def _remove_line!(line)
          { d: { result: self }, code: :ok }
        end

        def _rename!(new_path)
          ::File.rename(@path, new_path)
          { d: { result: PathMapper.new(new_path) }, code: :renamed }
        end

        def _delete!(full: false)
          { d: { result: self }, code: :ok }
        end

        def _override!(content)
          if content.empty?
            { d: { result: self.delete! }, code: :deleted }
          else
            dummy_mapper = PathMapper.new(@path.dirname.join(".#{@name}.tmp"))._file_puts(content)
            if self.nil? or !self.compare_with(dummy_mapper)
              ::File.rename(dummy_mapper.path, @path)
              { d: { result: PathMapper.new(@path) }, code: :overrided }
            else
              { d: { result: dummy_mapper.path.delete }, code: :ok }
            end
          end
        end

        def compare_with(mapper)
          self.md5 == mapper.md5
        end

        def check(line)
          false
        end

        def md5
          Digest::MD5.new.digest(self.value)
        end

        def diff(context)
          context = _with_separator(context) unless context.nil?
          diff = Diffy::Diff.new(context, _with_separator(self.value)).to_s
          diff.empty? ? nil : diff
        end

        protected

        def _file_puts(content, file_mode='w')
          return self if content.to_s.empty?
          self.parent.create!
          ::File.open(@path, file_mode) {|f| f.puts(content) }
          PathMapper.new(@path)
        end
      end
    end
  end
end
