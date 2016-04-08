module PathMapper
  module Node
    module Base
      module File
        attr_accessor :changes_overlay

        def method_missing(m, *args, &block)
          kwargs = self.kwargs(args)
          self.with_logger(logger: kwargs.delete(:logger)) do
            self.changes_overlay = kwargs.delete(:change_overlay) if kwargs.key? :change_overlay
            args << kwargs unless kwargs.empty?
            self.changes_overlay.send("_#{m}", *args, &block)[:d][:result] if self.respond_to?("_#{m}")
          end
        end

        def changes_overlay
          @changes_overlay || self
        end

        def _create!
          { d: { result: self }, code: :ok }
        end

        def _put!(content)
          { d: { result: self }, code: :ok }
        end

        def _safe_put!(content)
          { d: { result: self }, code: :ok }
        end

        def _append!(content)
          { d: { result: self }, code: :ok }
        end

        def _remove_line!(line)
          { d: { result: self }, code: :ok }
        end

        def _rename!(new_path)
          self.with_dry_run do |dry_run|
            if dry_run
              self.storage[new_path] = self.storage_file_delete(@path)
            else
              ::File.rename(@path, new_path)
            end
          end
          { d: { result: self._create_node(new_path) }, code: :renamed }
        end

        def _delete!(full: false)
          { d: { result: self }, code: :ok }
        end

        def _override!(content)
          if content.empty?
            { d: { result: self.delete!(logger: false) }, code: :deleted }
          else
            self.with_dry_run do |dry_run|
              tmp_mapper = self._create_node(@path.dirname.join(".#{@name}.tmp")).put!(content, logger: false)

              if self.nil? or !self.compare_with(tmp_mapper)
                if dry_run
                  self.storage[@path] = tmp_mapper.raw_value
                else
                  tmp_mapper.rename!(@path, logger: false)
                end
                code = :overrided
              else
                tmp_mapper.delete!(logger: false)
                code = :ok
              end

              { d: { result: self._create_node(@path) }, code: code }
            end
          end
        end

        def compare_with(obj)
          return if obj.nil?
          if obj.respond_to? :node? and obj.node?
            self.md5 == obj.md5
          else
            self.md5 == Digest::MD5.new.digest(obj.to_s)
          end
        end

        def check(line)
          false
        end

        def md5
          Digest::MD5.new.digest(self.value)
        end

        def diff(content)
          content = with_line_separator(content.chomp) unless content.nil?
          diff = Diffy::Diff.new(content, self.raw_value, diff: '-U 3').to_s
          diff.empty? ? nil : diff
        end

        def custom_diff(a, b)
          Diffy::Diff.new(a, b).to_s
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

          self._create_node(@path)
        end

        def _general_options
          super[:changes_overlay] = @changes_overlay if @changes_overlay != self
        end
      end
    end
  end
end
