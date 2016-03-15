module PathMapper
  module Node
    module File
      module Erb
        @@context_options = {}

        def erb(**kwargs)
          options = @@context_options.merge(kwargs)
          ERB.new(self.value).result(OpenStruct.new(options).instance_eval { binding })
        rescue Exception => e
          raise NetStatus::Exception, e.net_status.merge!( code: :erb_error, data: { error: "#{e.backtrace.first.sub! '(erb)', self.path.to_s}: #{e.message}" })
        end
      end
    end
  end
end