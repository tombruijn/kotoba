require "maruku"

class Kotoba::Export::Document
  def self.generate(filename)
    pdf = Kotoba::Export::Document.new do |prawn|
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
  #
  # @param strings [Array] content to be added to the document.
  #
  def parse_and_add_content(strings)
    strings.each_with_index do |string, index|
      if string == Kotoba::Template::PAGE_BREAK_TAG
        start_new_page
      else
        markdown = Maruku.new(string)
        markdown.to_prawn(self)

        if insert_section_spacing?(strings, index)
          move_down Kotoba.config.section_spacing
        end
      end
    end
  end

  # Returns boolean if section spacing should be added to the document.
  # Will return false if section support is turned off.
  # Will return false if the next section is a page break.
  #
  # @param sections [Array] array of strings/sections and page breaks.
  # @param current_index [Integer] current index of the sections array.
  #   Will be used to search ahead in the array.
  #
  def insert_section_spacing?(sections, current_index)
    return false unless Kotoba.config.support_sections
    current_section = sections[current_index]
    next_section = sections[current_index + 1]
    current_section != sections.last &&
      next_section != Kotoba::Template::PAGE_BREAK_TAG
  end

  # Returns if the template is from a new chapter or not.
  # Remembers the last asked template for future calls.
  #
  # @return [Boolean] if template is a new chapter (based on previous calls)
  #
  def new_chapter?(template)
    return false unless Kotoba.config.chapter_on_new_page
    template_dir = File.dirname(template.file)
    is_new_dir = !(@last_dir.nil? || @last_dir == template_dir)
    @last_dir = template_dir
    is_new_dir
  end
end
