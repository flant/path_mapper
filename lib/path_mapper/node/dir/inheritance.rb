module PathMapper
  module Node
    module Dir
      module Inheritance
        attr_writer :inheritance

        def inheritance
          @inheritance ||= []
        end

        def <<(mapper)
          self.inheritance << mapper
        end

        def f(m, **kwargs)
          def with_inheritance(obj)
            obj.inheritance = self.inheritance.select {|inheritor| !inheritor.f(query).empty? } if obj.dir?
            obj
          end

          base_resp = with_inheritance(PathMapper.new(@path.join(m.to_s)))
          self.inheritance.each do |inherit|
            unless (resp = with_inheritance(inherit.f(m))).nil?
              return resp
            end
          end if base_resp.empty?
          (base_resp.empty? and kwargs.key? :default) ? kwargs[:default] : base_resp
        end

        def grep(reg, recursive=false, path=@path)
          files_iterator = super
          self.inheritance.each do |inheritor|
            files_iterator.files += super(req, recursive, inheritor.path)
          end
          files_iterator
        end
      end
    end
  end
end