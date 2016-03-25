module PathMapper
  module Node
    module Dir
      module Inheritance
        module Base
          attr_writer :inheritance

          def inheritance
            @inheritance ||= []
          end

          def <<(mapper)
            self.inheritance << mapper
          end

          def f(m, overlay: true, **kwargs)
            def with_inheritance(obj, **kwargs)
              if obj.respond_to? :dir? and obj.dir?
                obj.inheritance = self.inheritance.map do |inheritor|
                  next if inheritor.path == obj.path.dirname
                  unless (resp = inheritor.f(obj.name, kwargs)).empty?
                    resp
                  end
                end.compact
              end
              obj
            end

            base_resp = nil
            ["#{m.to_s}.erb", m.to_s].each {|fname| base_resp = with_inheritance(self._create_node(@path.join(fname)), kwargs) if base_resp.nil? }
            resp = [base_resp]
            self.inheritance.each do |inherit|
              unless (resp_ = with_inheritance(inherit.f(m, kwargs), kwargs)).nil?
                if overlay
                  return resp_
                else
                  resp << resp_
                end
              end
            end if !overlay || (overlay and base_resp.empty?)

            if base_resp.empty? and kwargs.key? :default
              kwargs[:default]
            else
              overlay ? resp.first : resp.select {|node| !node.is_a? Null }
            end
          end
        end
      end
    end
  end
end