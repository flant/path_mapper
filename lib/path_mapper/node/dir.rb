module PathMapper
  module Node
    module Dir
      include Base
      include File
      include Grep
      include Representation
      include Inheritance

      def method_missing(m, *args, &block)
        resp = self.f(m, self.kwargs(args)) if (resp = super).is_a? NilClass # Base::File
        resp
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