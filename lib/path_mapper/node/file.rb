module PathMapper
  module Node
    module File
      include Base

      def method_missing(m, *args, &block)
        (@content ||= self.value).send(m, *args, &block)
      end

      def grep(reg, recursive: false, path: @path, **kwargs)
        []
      end

      def delete!(full: false)
        @path.delete
        if (dir_node = DirNode.new(@path.dirname)).empty?
          dir_node.delete!(full: full)
        end
        NullNode.new(@path)
      end

      def to_s
        self.value
      end

      def lines
        self.to_s.lines.map {|l| l.strip }
      end

      def value
        ::File.read(@path).strip
      end

      def bool
        value == 'yes'
      end
    end
  end
end