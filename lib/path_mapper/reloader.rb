module PathMapper
  module Reloader
    EXCLUDED_METHODS = [:path, :name, :parent, :put!, :append!, :to_pathname, :inheritance, :erb_options, :erb_options=]

    def self.included(base)
      base.class_eval do
        methods = base.public_instance_methods - Object.public_instance_methods
        methods.each do |name|
          next if EXCLUDED_METHODS.include? name

          with = :"#{name}_with_reload"
          without = :"#{name}_without_reload"
          @__last_methods_added = [name, with, without]

          define_method with do |*args, &block|
            obj = self.create_node(@path)
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