module PathMapper
  module Node
    module Base
      attr_reader :path
      attr_reader :name

      def initialize(path)
        @path = Pathname.new(path)
        @name = @path.basename.to_s
      end

      def parent
        PathMapper.new(@path.parent)
      end

      def grep(reg, recursive=false, path=@path)
        path_ = "#{path}#{'/**' if recursive}/*"
        files = ::Dir[path_].select {|f| f =~ reg }
        FilesIterator.new(files)
      end

      def grep_dirs(recursive=false)
        self.grep(/.*/, recursive).select {|n| n.is_a? Dir }
      end

      def grep_files(recursive=false)
        self.grep(/.*/, recursive).select {|n| n.is_a? File }
      end

      def delete!(full: false)
      end

      def put!(content)
        return self if content.empty?
        @path.dirname.mkpath
        ::File.open(@path, 'w') {|f| f.write(content) }
        FileNode.new(@path)
      end

      def dir?
        @path.directory?
      end

      def file?
        @path.file?
      end

      def value
        nil
      end

      def int
        self.value.to_i
      end

      def float
        self.value.to_f
      end

      def json
        JSON.load(self.value)
      end

      def to_s
        @path.to_s
      end

      def to_str
        self.to_s
      end

      def inspect
        self.to_s
      end

      def to_pathname
        @path
      end
    end
  end
end