# require 'path_mapper/version'

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

    def f(m)
      PathMapper.new(File.join(@_path, m.to_s))
    end

    def _grep(reg, recursive=false)
      path = "#{@_path}#{'/**' if recursive}/*"
      files = Dir[path].select {|f| f =~ reg }
      FilesIterator.new(files)
    end

    def method_missing(m, **kwargs)
      obj = self.f(m)
      (obj.empty? and kwargs.key? :default) ? kwargs[:default] : obj
    end
  end

  class FileNode
    include BaseNode

    def method_missing(m)
      (@content ||= self.to_s).send(m)
    end

    def to_s
      File.read(@_path).strip
    end
  end

  class NullNode < BasicObject
    include BaseNode
    def method_missing(m, **kwargs)
      if nil.respond_to? m
        nil.send m
      else
        kwargs.key?(:default) ? kwargs[:default] : NullNode.new([@_path, m.to_s].join(::File::SEPARATOR))
      end
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
