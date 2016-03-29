module PathMapper
  module Node
    module Dir
      module File
        def create!
          self
        end

        def put!(content)
          nil
        end

        def append!(content)
          nil
        end

        def override!(content)
          nil
        end

        def delete!(full: false)
          @path.rmtree

          path_ = @path.parent
          while path_.children.empty?
            path_.rmdir
            path_ = path_.parent
          end if full

          NullNode.new(@path)
        end
      end
    end
  end
end
