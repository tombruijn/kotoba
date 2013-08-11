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
    book.templates.each do |template|
      start_new_page if new_chapter?(template)
      add_chapter(template)
    end
  end

  # Adds a template to the document.
  #
  # @param template [Kotoba::Template] template to be added
  #
  def add_chapter(template)
    if config.support_sections
      parse_and_add_content template.sections
    else
      parse_and_add_content template.source
    end
  end

  protected

  # Parses the strings in the given array. Any Markdown syntax will be
  # added to the document with the intended style.
  # (Also accepts strings.)
  #
  # @param source [Array/String] content to be added to the document.
  #
  def parse_and_add_content(source)
    source = [source] unless source.is_a?(Array)
    source.each do |string|
      markdown = Maruku.new(string)
      markdown.to_prawn(self)
    end
  end

  # Returns if the template is from a new chapter or not.
  # Remembers the last asked template for future calls.
  #
  # @return [Boolean] if template is a new chapter (based on previous calls)
  #
  def new_chapter?(template)
    return false unless config.chapter_on_new_page
    template_dir = File.dirname(template.file)
    is_new_dir = !(@last_dir.nil? || @last_dir == template_dir)
    @last_dir = template_dir
    is_new_dir
  end
end
