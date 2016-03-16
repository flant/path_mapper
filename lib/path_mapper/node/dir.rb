module PathMapper
  module Node
    module Dir
      include Base

      def method_missing(m, *args, **kwargs, &block)
        self.f(m, kwargs)
      end

      def f(m, **kwargs)
        def with_file_node(fname, **kwargs)
          if (obj = PathMapper.new(@path.join(fname))).file?
            yield obj
          end
        end

        res = case m.to_s
          when /(.*)(?=\?)/ then with_file_node($1) {|node| node.bool } || false
          when /(.*)(?=_val)/ then with_file_node($1) {|node| node.value }
          when /(.*)(?=_lines)/ then with_file_node($1) {|node| node.lines }
        end
        res.nil? ? super : res
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