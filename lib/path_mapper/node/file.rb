module PathMapper
  module Node
    module File
      include Base
      include File
      include Representation
      include Grep

      def method_missing(m, *args, &block)
        (@content ||= self.value).send(m, *args, &block)
      end
    end
  end
end