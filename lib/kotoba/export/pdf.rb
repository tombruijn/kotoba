require "maruku"

module Kotoba
  module Export
    class Pdf < Base
      def export
        Document.generate(file) do |prawn|
          prawn.book.templates.each do |template|
            # Create new page on new chapter
            if config.chapter_on_new_page && new_chapter?(template)
              prawn.start_new_page
            end
            # Sections support
            if prawn.config.support_sections
              template.sections.each do |section|
                markdown = Maruku.new(section)
                markdown.to_prawn(prawn)
                prawn.text " "
              end
            # Default behavior
            else
              markdown = Maruku.new(template.source)
              markdown.to_prawn(prawn)
            end
          end

          # Headers and footers
          prawn.add_recurring_elements!
          # PDF navigation
          prawn.outline!
        end
      end

      def extension
        @extension ||= :pdf
      end

      protected

      # Returns if the template is from a new chapter or not.
      # Remembers the last asked template for future calls.
      #
      # @return [Boolean] if template is a new chapter (based on previous calls)
      #
      def new_chapter?(template)
        template_dir = File.dirname(template.file)
        is_new_dir = !(@last_dir.nil? || @last_dir == template_dir)
        @last_dir = template_dir
        is_new_dir
      end
    end
  end
end
