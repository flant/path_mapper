require 'path_mapper/version'
require 'pathname'

module PathMapper
  def self.new(path)
    if File.exists? path
      if File.directory? path
        return DirNode.new(path)
      elsif !File.read(path).strip.empty?
        return FileNode.new(path)
      end
    end
    NullNode.new(path)
  end

  module BaseNode
    attr_reader :path
    attr_reader :name

    def initialize(path)
      @path = Pathname.new(path)
      @name = @path.basename.to_s
    end

    def parent
      PathMapper.new(@path.parent)
    end

    def grep(reg, recursive=false)
      path = "#{@path}#{'/**' if recursive}/*"
      files = Dir[path].select {|f| f =~ reg }
      FilesIterator.new(files)
    end

    def grep_dirs(recursive=false)
      self.grep(/.*/, recursive).select {|n| n.is_a? DirNode }
    end

    def grep_files(recursive=false)
      self.grep(/.*/, recursive).select {|n| n.is_a? FileNode }
    end

    def delete!(full: false)

    end

    def put!(content)
      return self if content.empty?
      @path.dirname.mkpath
      File.open(@path, 'w') {|f| f.write(content) }
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

  class DirNode
    include BaseNode

    def method_missing(m, *args, **kwargs, &block)
      if m.to_s.end_with? '?'
        obj = PathMapper.new(@path.join(m.to_s[/[^?]*/]))
        obj.file? ? obj.bool : false
      else
        self.f(m, **kwargs)
      end
    end

    def f(m, **kwargs)
      obj = PathMapper.new(@path.join(m.to_s))
      (obj.empty? and kwargs.key? :default) ? kwargs[:default] : obj
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

  class FileNode
    include BaseNode

    def method_missing(m, *args, &block)
      (@content ||= self.value).send(m, *args, &block)
    end

    def grep(reg, recursive=false)
      []
    end

    def delete!(full: false)
      @path.delete
      DirNode.new(@path.dirname).delete!(full: full)
      NullNode.new(@path)
    end

    def value
      File.read(@path).strip
    end

    def bool
      value == 'yes'
    end
  end

  class NullNode
    include BaseNode

    def method_missing(m, *args, **kwargs, &block)
      nil.send m, *args, &block
    rescue ::NoMethodError
      self.f(m, **kwargs)
    end

    def f(m, **kwargs)
      kwargs.key?(:default) ? kwargs[:default] : NullNode.new(@path.join(m.to_s))
    end

    def grep(reg, recursive=false)
      []
    end

    def create!
      @path.mkpath
      DirNode.new(@path)
    end

    def nil?
      true
    end

    def empty?
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

  module Mixin
    def to_pathmapper
      PathMapper.new(self)
    end
  end
end

::Pathname.send(:include, PathMapper::Mixin)
