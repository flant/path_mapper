module PathMapper
  module Node
    module Null
      module Representation
        def to_s
          ''
        end

        def nil?
          true
        end

        def empty?
          true
        end

        def any?
          false
        end
      end
    end
  end
end
