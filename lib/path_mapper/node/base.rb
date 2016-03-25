module PathMapper
  module Node
    module Base
      include Grep
      include File
      include Representation

      attr_reader :path
      attr_reader :name

      def initialize(path, **kwargs)
        @path = Pathname.new(path)
        @name = @path.basename.to_s
      end

      def parent
        self._create_node(@path.parent)
      end

      protected

      def _create_node(path)
        PathMapper.new(path, self._general_options)
      end

      def _general_options
        {}
      end
    end
  end
end