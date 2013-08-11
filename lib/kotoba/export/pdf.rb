module Kotoba
  module Export
    class Pdf < Base
      def export
        Document.generate(file)
      end

      def extension
        @extension ||= :pdf
      end
    end
  end
end
