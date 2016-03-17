module PathMapper
  module Node
    module Dir
      module Erb
        attr_reader :erb_options

        def initialize(path, erb_options={})
          super(path)
          self.erb_options = erb_options
        end

        def erb_options=(options)
          @erb_options = options
          self.inheritance.each {|m| m.erb_options = options }
        end

        protected

        def general_options
          super[:erb_options] = self.erb_options
        end
      end
    end
  end
end