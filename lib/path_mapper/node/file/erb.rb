module PathMapper
  module Node
    module File
      module Erb
        include Dir::Erb

        def erb_options=(options)
          @erb_options = options
        end

        def erb(script)
          ERB.new(script).result(OpenStruct.new(self.erb_options).instance_eval { binding })
        rescue Exception => e
          raise NetStatus::Exception, { code: :erb_error, data: { error: "#{e.backtrace.first.sub! '(erb)', self.path.to_s}: #{e.message}" } }
        end

        def value
          if self.name.end_with?('.erb')
            self.erb(super)
          else
            super
          end
        end
      end
    end
  end
end