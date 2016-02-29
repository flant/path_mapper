require 'path_mapper/version'

module PathMapper
  class Mapper
    attr_reader :path
    attr_reader :_name

    def initialize(path)
      @path = path
      @_name = PathMapper.get_file_name(path)
    end

    def f(m)
      if File.exists? path = File.join(@path, m.to_s)
        if File.directory? path
          Mapper.new(path)
        else
          File.read(path).strip
        end
      else
        NullObject.new(m.to_s)
      end
    end

    def _grep(reg, recursive=false)
      path = "#{@path}#{'/**' if recursive}/*"
      files = Dir[path].select {|f| f =~ reg }
      FilesIterator.new(files)
    end

    def method_missing(m, *args, &block)
      self.f(m)
    end
  end

  class NullObject < BasicObject
    attr_reader :_name

    def initialize(name)
      @_name = name
    end

    def method_missing(m, *args, &block)
      if nil.respond_to? m
        nil.send m, *args, &block
      else
        @_name = m.to_s
        self
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
  end

  class FilesIterator
    include Enumerable

    def initialize(files)
      @files = files
    end

    def each
      @files.each do |f|
        obj = if File.directory? f
          [PathMapper.get_file_name(f), Mapper.new(f)]
        else
          [PathMapper.get_file_name(f), File.read(f)]
        end
        yield obj
      end
    end
  end

  def self.get_file_name(name)
    name.scan(/[^\/]+/).last
  end
end
