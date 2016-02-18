require 'path_mapper/version'

module PathMapper
  class Mapper
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def f(m)
      if File.exists? path = File.join(@path, m.to_s)
        if File.directory? path
          Mapper.new(path)
        else
          File.read(path)
        end
      else
        NullObject.new
      end
    end

    def method_missing(m, *args, &block)
      self.f(m)
    end
  end

  class NullObject < BasicObject
    def method_missing(m, *args, &block)
      if nil.respond_to? m
        nil.send m, *args, &block
      else
        self
      end
    end

    def empty()
      true
    end

    def any?()
      false
    end
  end
end
