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
          ["#{m.to_s}.erb", m.to_s].each {|fname| base_resp = with_inheritance(self.create_node(@path.join(fname)), kwargs) if base_resp.nil? }
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

        def grep(reg, recursive: false, path: @path, overlay: true)
          files_iterator = super
          self.inheritance.each do |inheritor|
            inheritor_files_iterator = super(reg, path: inheritor.path)
            files_iterator.files += if overlay
              inheritor_files_iterator.files.select {|f| !files.any? {|f_| f_.basename[/.*[^\.erb]/] == f.basename[/.*[^\.erb]/] } }
            else
              inheritor_files_iterator.files
            end
          end
          files_iterator
        end
      end
    end
  end
end