require 'path_mapper/version'

module PathMapper
  def self.new(path)
    if File.exists? path
      if File.directory? path
        return DirNode.new(path) if Dir["#{path}/*"].any?
      elsif !File.read(path).strip.empty?
        return FileNode.new(path)
      end
    end
    NullNode.new(path)
  end

  module BaseNode
    attr_reader :_path
    attr_reader :_name

    def initialize(path)
      @_path = path
      @_name = get_file_name(path)
    end

    def _grep(reg, recursive=false)
      path = "#{@_path}#{'/**' if recursive}/*"
      files = Dir[path].select {|f| f =~ reg }
      FilesIterator.new(files)
    end

    def _grep_dirs(recursive=false)
      self._grep(/.*/).select {|n| n.is_a? DirNode }
    end

    def _grep_files(recursive=false)
      self._grep(/.*/).select {|n| n.is_a? FileNode }
    end

    def get_file_name(name)
      name.scan(/[^\/]+/).last
    end

    def to_s
      @_path
    end

    def inspect
      self.to_s
    end

    alias_method :to_str, :to_s
  end

  class DirNode
    include BaseNode

    def method_missing(m, *args, **kwargs, &block)
      self.f(m, **kwargs)
    end

    def f(m, **kwargs)
      obj = PathMapper.new(File.join(@_path, m.to_s))
      (obj.empty? and kwargs.key? :default) ? kwargs[:default] : obj
    end
  end

  class FileNode
    include BaseNode

    def method_missing(m, *args, &block)
      (@content ||= self.to_s).send(m, *args, &block)
    end

    def _grep(reg, recursive=false)
      []
    end

    def to_s
      File.read(@_path).strip
    end
  end

  class NullNode < BasicObject
    include BaseNode

    def method_missing(m, *args, **kwargs, &block)
      if nil.respond_to? m
        nil.send m, *args, &block
      else
        self.f(m, **kwargs)
      end
    end

    def f(m, **kwargs)
      kwargs.key?(:default) ? kwargs[:default] : NullNode.new([@_path, m.to_s].join(::File::SEPARATOR))
    end

    def _grep(reg, recursive=false)
      []
    end

    def nil?
      true
    end

    def empty
      true
    end

    def any?
      false
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
