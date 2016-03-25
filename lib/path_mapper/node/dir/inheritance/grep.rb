module PathMapper
  module Node
    module Dir
      module Inheritance
        module Grep
          def grep(reg, recursive: false, path: @path, overlay: true)
            files_iterator = super
            self.inheritance.each do |inheritor|
              inheritor_files_iterator = super(reg, path: inheritor.path)
              files_iterator.files += if overlay
                inheritor_files_iterator.files.select {|f| !files_iterator.files.any? {|f_| f_.basename.to_s[/(.*(?=\.erb))|(.*)/] == f.basename.to_s[/(.*(?=\.erb))|(.*)/] } }
              else
                inheritor_files_iterator.files
              end
            end
            files_iterator
          end
        end
      end
    end
  end
end