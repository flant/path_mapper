module PathMapper
  module Helper
    module Debug
      def logger
        Thread.current[:logger]
      end

      def logger=(state)
        Thread.current[:logger] = state
      end

      def with_logger(logger: nil)
        old = self.logger
        self.logger = nil if logger.is_a? FalseClass
        yield
      ensure
        self.logger = old
      end
    end
  end
end