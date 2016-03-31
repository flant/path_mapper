module PathMapper
  module Node
    module Null
      include Base
      include File
      include Representation

      def method_missing(m, *args, &block)
        resp = nil.send m, *args, &block if (resp = super).is_a? NilClass # Base::File
        resp
      rescue ::NoMethodError
        self.f(m, self.kwargs(args))
      end

      def f(m, **kwargs)
        kwargs.key?(:default) ? kwargs[:default] : NullNode.new(@path.join(m.to_s))
      end
    end
  end
end