require "maruku"

module Kotoba
  module Export
    class Pdf < Base
      def export
        Document.generate(file, prawn_options) do |prawn|
          prawn.book.templates.each do |template|
            if template.metadata && template.metadata["title"]
              section = { :name => template.metadata["title"], :file => template.file }
              prawn.sections << section
              prawn.current_section = section[:file]
            end

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
          prawn.sections.each do |section|
            prawn.outline.section(section[:name], :destination => section[:page]) do
              prawn.list[section[:file]].each do |header|
                prawn.outline.page(:title => header[:name], :destination => header[:page])
              end
            end
          end
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
