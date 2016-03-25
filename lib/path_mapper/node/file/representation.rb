module PathMapper
  module Node
    module File
      module Representation
        def empty?
          false
        end

        def value
          ::File.read(@path).strip
        end

        def bool
          value == 'yes'
        end

        def lines
          self.value.lines.map {|l| l.strip }
        end

        def to_s
          self.value
        end
      end
    end
  end
end
