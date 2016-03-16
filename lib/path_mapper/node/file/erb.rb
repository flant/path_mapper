module PathMapper
  module Node
    module File
      module Erb
        def self.included(base)
          base.send(:extend, ClassMethods)
        end

        def erb(script)
          ERB.new(script).result(OpenStruct.new(self.class.erb_options).instance_eval { binding })
        rescue Exception => e
          raise NetStatus::Exception, e.net_status.merge!( code: :erb_error, data: { error: "#{e.backtrace.first.sub! '(erb)', self.path.to_s}: #{e.message}" })
        end

        def value
          if self.name.end_with?('.erb')
            self.erb(super)
          else
            super
          end
        end

        module ClassMethods
          def erb_options
            @@erb_options ||= {}
          end

          def erb_options=(val)
            @@erb_options = val
          end
        end
      end
    end
  end
end