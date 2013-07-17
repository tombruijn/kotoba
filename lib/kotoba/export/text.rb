module Kotoba
  module Export
    class Text < Base
      def export
        content = book.to_html

        File.open(file, "w") do |file|
          file << content
        end
      end

      def extension
        @extension ||= :txt
      end
    end
  end
end
