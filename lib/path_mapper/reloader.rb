module PathMapper
  module Reloader
    def self.included(base)
      base.class_eval do
        methods = base.public_instance_methods - Object.public_instance_methods
        methods.each do |name|
          with = :"#{name}_with_reload"
          without = :"#{name}_without_reload"
          @__last_methods_added = [name, with, without]

          define_method with do |*args, &block|
            obj = self._create_node(@path)
            if obj.is_a? self.class
              self.send(without, *args, &block)
            else
              obj.send(without, *args, &block)
            end
          end

          alias_method without, name
          alias_method name, with
        end
      end
    end
  end
end