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
          resp = self._file_puts(content, 'a+')
          diff = self.diff(context)
          code = diff.empty? ? :ok : :modified
          { d: { result: resp, diff: diff }, code: code }
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
          self.with_dry_run do |dry_run|
            if dry_run
              ::File.rename(@path, new_path)
            else
              self.storage[new_path] = self.storage_file_delete(@path)
            end
          end
          { d: { result: PathMapper.new(new_path) }, code: :renamed }
        end

        def _delete!(full: false)
          { d: { result: self }, code: :ok }
        end

        def _override!(content)
          if content.empty?
            self._delete!
          else
            self.with_dry_run do |dry_run|
              tmp_mapper = PathMapper.new(@path.dirname.join(".#{@name}.tmp"))._file_puts(content)

              if self.nil? or !self.compare_with(tmp_mapper)
                if dry_run
                  self.storage[@path] = tmp_mapper.raw_value
                else
                  ::File.rename(tmp_mapper.path, @path)
                end
                code = :overrided
              else
                tmp_mapper.path.delete unless dry_run
                code = :ok
              end

              { d: { result: PathMapper.new(@path) }, code: code }
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
          context = with_line_separator(context) unless context.nil?
          diff = Diffy::Diff.new(context, self.raw_value, diff: '-U 3').to_s
          diff.empty? ? nil : diff
        end

        protected

        def _file_puts(content, file_mode='w')
          return self if content.to_s.empty?
          self.parent.create!

          with_dry_run do |dry_run|
            if dry_run
              self.storage[@path] = case file_mode
                when 'w' then with_line_separator(content)
                when 'a+' then self.storage[@path].to_s + with_line_separator(content)
              end
            else
              ::File.open(@path, file_mode) {|f| f.puts(content) }
            end
          end

          PathMapper.new(@path)
        end
      end
    end
  end
end
