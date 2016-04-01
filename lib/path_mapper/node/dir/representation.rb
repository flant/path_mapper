module PathMapper
  module Node
    module Dir
      module Representation
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
      end
    end
  end
end