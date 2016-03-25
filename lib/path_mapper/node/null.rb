module PathMapper
  module Node
    module Null
      include Base
      include File
      include Representation

      def method_missing(m, *args, **kwargs, &block)
        nil.send m, *args, &block
      rescue ::NoMethodError
        self.f(m, **kwargs)
      end

      def f(m, **kwargs)
        kwargs.key?(:default) ? kwargs[:default] : NullNode.new(@path.join(m.to_s))
      end
    end
  end
end