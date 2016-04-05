module PathMapper
  module Helpers
    include Helper::Debug
    include Helper::Logger
    include Helper::Storage

    def kwargs(args)
      case args.last
        when Hash then args.pop
        else {}
      end
    end

    def with_line_separator(arg)
      if arg.is_a? Array
        with_line_separator(arg.join("\n"))
      else
        "#{arg}\n"
      end
    end
  end
end