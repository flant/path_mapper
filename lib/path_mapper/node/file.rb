module PathMapper
  module Node
    module File
      include Base
      include File
      include Representation
      include Grep

      def method_missing(m, *args, &block)
        resp = (@content ||= self.value).send(m, *args, &block) if (resp = super).is_a? NilClass # Base::File
        resp
      end
    end
  end
end