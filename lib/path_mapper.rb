require 'path_mapper/version'

module PathMapper
  def self.new(path)
    if File.exists? path
      if File.directory? path
        DirNode.new(path)
      else
        FileNode.new(path)
      end
    else
      NullNode.new(path)
    end
  end

  module BaseNode
    attr_reader :path
    attr_reader :_name

    def initialize(path)
      @path = path
      @_name = get_file_name(path)
    end

    def get_file_name(name)
      name.scan(/[^\/]+/).last
    end
  end

  class DirNode
    include BaseNode

    def f(m)
      PathMapper.new(File.join(@path, m.to_s))
    end

    def _grep(reg, recursive=false)
      path = "#{@path}#{'/**' if recursive}/*"
      files = Dir[path].select {|f| f =~ reg }
      FilesIterator.new(files)
    end

    def method_missing(m, *args, &block)
      self.f(m)
    end

    def to_s
      @path
    end
  end

  class FileNode
    include BaseNode

    def method_missing(m, *args, &block)
      (@content ||= self.to_s).send(m)
    end

    def to_s
      File.read(@path).strip
    end
  end

  class NullNode < BasicObject
    include BaseNode

    def method_missing(m, *args, &block)
      if nil.respond_to? m
        nil.send m, *args, &block
      else
        NullNode.new([@path, m.to_s].join(::File::SEPARATOR))
      end
    end

    def _grep(reg, recursive=false)
      []
    end

    def empty
      true
    end

    def any?
      false
    end

    def to_s
      @path
    end
  end

  class FilesIterator
    include Enumerable

    def initialize(files)
      @files = files
    end

    def each
      @files.each do |f|
        yield PathMapper.new(f)
      end
    end
  end
end
