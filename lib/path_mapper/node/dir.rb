module PathMapper
  module Node
    module Dir
      include Base
      include Dir::Inheritance

      def method_missing(m, *args, **kwargs, &block)
        self.f(m, kwargs)
      end

      def f(m, **kwargs)
        if m.to_s.end_with? '?'
          obj = PathMapper.new(@path.join(m.to_s[/[^?]*/]))
          obj.file? ? obj.bool : false
        elsif m.to_s.end_with? '_erb'
          obj = PathMapper.new(@path.join("#{m.to_s[/.*(?=_erb)/]}.erb"))
          obj.file? ? obj.erb(**kwargs) : super
        else
          super
        end
      end

      def create!
        self
      end

      def delete!(full: false)
        @path.rmtree

        path_ = @path.parent
        while path_.children.empty?
          path_.rmdir
          path_ = path_.parent
        end if full

        NullNode.new(@path)
      end

      def empty?
        @path.children.empty?
      end
    end
  end
end