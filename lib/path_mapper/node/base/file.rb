module PathMapper
  module Node
    module Base
      module File
        def create!
          self
        end

        def put!(content)
          self._file_puts(content)
        end

        def safe_put!(content)
          self.put!(content) unless self.file?
        end

        def append!(content)
          self._file_puts(content, 'a+')
        end

        def safe_append!(content)
          self.append!(content) unless self.check(content)
        end

        def remove_line!(line)
          self
        end

        def rename!(new_path)
          ::File.rename(@path, new_path)
          PathMapper.new(new_path)
        end

        def delete!(full: false)
          self
        end

        def override!(content)
          if content.empty?
            self.delete!
          else
            PathMapper.new(@path.dirname.join(".#{@name}.tmp")).put!(content).tap do |dummy_mapper|
              if self.nil? or !self.compare_with(dummy_mapper)
                dummy_mapper.rename!(@path)
              else
                dummy_mapper.delete!
              end
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

        protected

        def _file_puts(content, file_mode='w')
          return self if content.to_s.empty?
          PathMapper.new(@path.dirname).create!
          ::File.open(@path, file_mode) {|f| f.puts(content) }
          PathMapper.new(@path)
        end
      end
    end
  end
end
