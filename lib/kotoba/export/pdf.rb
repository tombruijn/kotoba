require "maruku"

module Kotoba
  module Export
    class Pdf < Base
      def export
        Document.generate(file, prawn_options) do |prawn|
          prawn.book.templates.each do |template|
            if prawn.config.support_sections
              template.sections.each do |section|
                markdown = Maruku.new(section)
                markdown.to_prawn(prawn)
                prawn.text " "
              end
            else
              markdown = Maruku.new(template.source)
              markdown.to_prawn(prawn)
            end
          end

          prawn.page_numbering!
          prawn.header!
          prawn.footer!
          prawn.outline!
        end
      end

      def prawn_options
        config.to_h
      end

      def extension
        @extension ||= :pdf
      end
    end
  end
end
