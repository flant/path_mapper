module PathMapper
  module Node
    module Base
      module Representation
        def dir?
          false
        end

        def file?
          false
        end

        def empty?
          true
        end

        def nil?
          false
        end

        def any?
        end

        def node?
          true
        end

        def value
          nil
        end

        def raw_value
          nil
        end

        def int
          self.value.to_i
        end

        def float
          self.value.to_f
        end

        def bool
        end

        def lines
          []
        end

        def json
          JSON.load(self.value)
        end

        def to_s
          @path.to_s
        end

        def to_str
          self.to_s
        end

        def to_pathname
          @path
        end

        def inspect
          self.to_s
        end
      end
    end
  end
end
