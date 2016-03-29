module PathMapper
  module Node
    module File
      module File
        def remove_line!(line)
          lines = self.lines.select {|l| l !~ Regexp.new(line) and l }
          if lines.empty?
            self.delete!
          else
            self._file_puts(lines.join(''))
          end
        end

        def delete!(full: false)
          @path.delete
          if full and (dir_node = DirNode.new(@path.dirname)).empty?
            dir_node.delete!(full: full)
          end
          PathMapper.new(path)
        end

        def check(line)
          self.lines.any? { |l| l =~ Regexp.new(line) }
        end
      end
    end
  end
end
