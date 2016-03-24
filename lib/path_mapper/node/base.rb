module PathMapper
  module Node
    module Base
      attr_reader :path
      attr_reader :name

      def initialize(path, **kwargs)
        @path = Pathname.new(path)
        @name = @path.basename.to_s
      end

      def parent
        self.create_node(@path.parent)
      end

      def grep(reg, recursive: false, path: @path, **kwargs)
        path_ = "#{path}#{'/**' if recursive}/*"
        files = ::Dir[path_].select {|f| f =~ reg }
        files.map! {|f| Pathname.new(f) }
        FilesIterator.new(files, self)
      end

      def grep_dirs(recursive: false, **kwargs)
        self.grep(/.*/, recursive: recursive, **kwargs).select {|n| n.is_a? Dir }
      end

      def grep_files(recursive: false, **kwargs)
        self.grep(/.*/, recursive: recursive, **kwargs).select {|n| n.is_a? File }
      end

      def put!(content)
        return self if content.empty?
        @path.dirname.mkpath
        ::File.open(@path, 'w') {|f| f.puts(content) }
        FileNode.new(@path)
      end

      def safe_put!(content)
        self.put!(content) unless self.file?
      end

      def safe_append!(content)
        unless self.dir?
          self.append!(content) unless self.to_s.lines.include? content
        end
      end

      def append!(content)
        return self if content.to_s.empty?
        @path.dirname.mkpath
        ::File.open(@path, 'a+') {|f| f.puts(content) }
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

      protected

      def create_node(path)
        PathMapper.new(path, self.general_options)
      end

      def general_options
        {}
      end
    end
  end
end