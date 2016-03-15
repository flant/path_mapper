module PathMapper
  module Node
    module File
      module Erb
        def erb(**kwargs)
          ERB.new(self.value).result(OpenStruct.new(kwargs).instance_eval { binding })
        rescue Exception => e
          raise NetStatus::Exception, e.net_status.merge!( code: :erb_error, data: { error: "#{e.backtrace.first.sub! '(erb)', self.path.to_s}: #{e.message}" })
        end
      end
    end
  end
end