require 'path_mapper/version'

module PathMapper
  class Mapper
    attr_reader :path
    attr_reader :_name

    def initialize(path)
      @path = path
      @_name = path.scan(/[^\/]+/).last
    end

    def f(m)
      if File.exists? path = File.join(@path, m.to_s)
        if File.directory? path
          Mapper.new(path)
        else
          File.read(path)
        end
      else
        NullObject.new(m.to_s)
      end
    end

    def _grep(reg)
      files = Dir["#{@path}/**/*"].select {|f| f =~ reg }
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
          Mapper.new(f)
        else
          File.read(f)
        end
        yield obj
      end
    end
  end
end

