module PathMapper
  module Reloader
    def self.included(base)
      base.class_eval do
        methods = []
        [Node::Base::File, Node::Base::Representation, Node::Base::Grep].each do |mod|
          methods += mod.public_instance_methods
        end
        exclude_methods = [:changes_overlay, :changes_overlay=]

        methods.each do |name|
          next if exclude_methods.include? name
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