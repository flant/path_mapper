module PathMapper
  module Node
    module Dir
      module File
        def _create!
          { d: { result: self }, code: :ok }
        end

        def _put!(content)
          { d: { result: self }, code: :ok }
        end

        def _append!(content)
          { d: { result: self }, code: :ok }
        end

        def _override!(content)
          { d: { result: self }, code: :ok }
        end

        def _delete!(full: false)
          @path.rmtree
          parent = self.parent
          parent.delete!(full: full) if parent.empty? and full
          { d: { result: PathMapper.new(@path) }, code: :deleted }
        end

        def md5
          nil
        end
      end
    end
  end
end
