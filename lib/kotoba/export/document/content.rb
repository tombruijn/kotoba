class Kotoba::Export::Document
  include Kotoba::Content

  def self.generate(filename)
    pdf = Kotoba::Export::Document.new do |prawn|
      # Add font assets
      prawn.register_fonts!
      # Add book content
      prawn.add_book!
      # Headers and footers
      prawn.add_recurring_elements!
      # PDF navigation
      prawn.outline!
    end
    pdf.render_file(filename)
  end

  # Adds the parsed book to the document.
  #
  def add_book!
    Kotoba.book.templates.each do |template|
      start_new_page if new_chapter?(template)
      add_chapter(template)
    end
  end

  # Adds a template to the document.
  #
  # @param template [Kotoba::Template] template to be added
  #
  def add_chapter(template)
    parse_and_add_content template.source
  end

  protected

  # Parses the strings in the given array. Any Markdown syntax will be
  # added to the document with the intended style.
  # Page breaks will be added to the document when PAGE_BREAK_TAG is detected.
  # Will add spacing between sections if active.
  #
  # @param strings [Array] content to be added to the document.
  #
  def parse_and_add_content(strings)
    strings.each_with_index do |string, index|
      if is_page_break? string
        start_new_page
      else
        markdown = Kramdown::Document.new(string)
        markdown.to_prawn(self)

        if insert_section_spacing?(strings, index)
          move_down Kotoba.config.section_spacing
        end
      end
    end
  end
end
