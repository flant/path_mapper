module PathMapper
  module Node
    module File
      module Representation
        def file?
          true
        end

        def empty?
          false
        end

        def value
          self.raw_value.strip
        end

        def raw_value
          with_dry_run do |dry_run|
            if dry_run
              self.storage[@path].to_s
            else
              ::File.read(@path)
            end
          end
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
