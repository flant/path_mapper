module PathMapper
  module Helper
    module Debug
      def dry_run
        Thread.current[:dry_run]
      end

      def dry_run=(state)
        Thread.current[:dry_run] = state
      end

      def with_dry_run
        old = self.dry_run
        yield old
      ensure
        self.dry_run = old
      end
    end
  end
end