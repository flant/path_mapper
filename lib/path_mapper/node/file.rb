module PathMapper
  module Node
    module File
      include Base
      include File::Erb

      def method_missing(m, *args, &block)
        (@content ||= self.value).send(m, *args, &block)
      end

      def grep(reg, recursive=false, path=@path)
        []
      end

      def delete!(full: false)
        @path.delete
        DirNode.new(@path.dirname).delete!(full: full)
        NullNode.new(@path)
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