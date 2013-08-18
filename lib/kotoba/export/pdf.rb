module Kotoba
  module Export
    class Pdf < Base
      # Exports the configured project to a PDF.
      #
      # @see Kotoba::Config for configuration options.
      # @see Kotoba::Layout for page layout and styling options.
      # @see Kotoba::Document for document generation.
      #
      def export
        Document.generate(file)
      end

      # Extension to use for the exported file.
      #
      # @return [Symbol]
      #
      def extension
        @extension ||= :pdf
      end
    end
  end
end
