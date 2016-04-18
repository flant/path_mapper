module PathMapper
  module Node
    module Dir
      module Representation
        def dir?
          true
        end

        def empty?
          self.with_dry_run do |dry_run|
            if dry_run
              empty = self.storage.select {|k,v| k.to_s.start_with? @path.to_s }.count == 1
              @path.directory? ? (@path.children - self.deleted_files).empty? : empty
            else
              @path.children.empty?
            end
          end
        end

        def to_hash
          def grep_node(mapper, h={})
            mapper.grep_dirs.each do |dir_mapper|
              h[dir_mapper.name] = grep_node(dir_mapper)
            end

            mapper.grep_files.each do |file_mapper|
              h[file_mapper.name] = file_mapper.raw_value
            end
            h
          end

          grep_node(self)
        end
      end
    end
  end
end