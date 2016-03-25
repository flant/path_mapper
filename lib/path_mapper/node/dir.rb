module PathMapper
  module Node
    module Dir
      include Base
      include File
      include Grep
      include Representation
      include Inheritance

      def method_missing(m, *args, **kwargs, &block)
        self.f(m, kwargs)
      end

      def f(m, **kwargs)
        def with_file_node(fname, **kwargs)
          if (obj = self._create_node(@path.join(fname))).file?
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
    end
  end
end