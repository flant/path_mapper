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

        def to_hash(eval_erb: false, exclude_files: [], exclude_dirs: [])
          def grep_node(mapper, eval_erb=false, exclude_files=[], exclude_dirs=[])
            h={}
            mapper.grep_dirs(exclude: exclude_dirs).each do |dir_mapper|
              h[dir_mapper.name] = grep_node(dir_mapper, eval_erb, exclude_files, exclude_dirs)
            end

            mapper.grep_files(exclude: exclude_files).each do |file_mapper|
              h[file_mapper.name] = eval_erb ? file_mapper.value : file_mapper.raw_value.chomp
            end
            h
          end

          grep_node(self, eval_erb, exclude_files, exclude_dirs)
        end
      end
    end
  end
end