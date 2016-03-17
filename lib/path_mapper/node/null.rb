module PathMapper
  module Node
    module Null
      include Base

      def method_missing(m, *args, **kwargs, &block)
        nil.send m, *args, &block
      rescue ::NoMethodError
        self.f(m, **kwargs)
      end

      def f(m, **kwargs)
        kwargs.key?(:default) ? kwargs[:default] : NullNode.new(@path.join(m.to_s))
      end

      def grep(reg, recursive: false, path: @path, **kwargs)
        []
      end

      def create!
        @path.mkpath
        DirNode.new(@path)
      end

      def nil?
        true
      end

      def empty?
        true
      end

      def any?
        false
      end

      def to_s
        ''
      end
    end
  end
end