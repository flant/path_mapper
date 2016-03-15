module PathMapper
  module Reloader
    def self.included(base)
      base.class_eval do
        methods = base.instance_methods - Object.instance_methods
        methods.each do |name|
          with = :"#{name}_with_reload"
          without = :"#{name}_without_reload"
          @__last_methods_added = [name, with, without]

          define_method with do |*args, &block|
            obj = PathMapper.new(@path)
            if obj.nil?
              method = (name == :method_missing) ? args.pop : name
              obj.send(method, *args, &block)
            else
              self.send(without, *args, &block)
            end
          end unless method_defined?(with)

          alias_method without, name
          alias_method name, with
        end
      end
    end
  end
end