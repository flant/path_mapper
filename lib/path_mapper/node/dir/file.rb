module PathMapper
  module Node
    module Dir
      module File
        def _create!
          { d: { result: self }, code: :ok }
        end

        def _override!(content)
          { d: { result: self }, code: :ok }
        end

        def _delete!(full: false)
          self.with_dry_run do |dry_run|
            if dry_run
              self.delete_storage_branch(@path)
            else
              @path.rmtree
            end
          end

          parent = self.parent
          parent.delete!(full: full) if parent.empty? and full

          { d: { result: self._create_node(@path) }, code: :deleted }
        end

        def md5
          nil
        end
      end
    end
  end
end
