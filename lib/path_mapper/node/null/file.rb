module PathMapper
  module Node
    module Null
      module File
        def _create!
          self.with_dry_run do |dry_run|
            if dry_run
              self.storage_tree(@path)
            else
              @path.mkpath
            end
          end
          { d: { result: PathMapper.new(@path) }, code: :created }
        end

        def _delete!(full: false)
          { d: { result: self }, code: :ok }
        end

        def _remove!(content)
          { d: { result: self }, code: :ok }
        end

        def _rename!(new_path)
          { d: { result: PathMapper.new(new_path) }, code: :ok }
        end

        def md5
          nil
        end
      end
    end
  end
end
