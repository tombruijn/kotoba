module Kotoba::Content
  ONLY_LINE_BREAKS = /\A(\n)+\z/
  YAML_METADATA = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m.freeze
  SECTION_SEPARATOR = /\n\n\n/.freeze
  PAGE_BREAK_TAG = "\n___PAGE___\n"
  # Split on ___PAGE___ but keep the key
  PAGE_BREAK_SPLITTER = /(?=#{PAGE_BREAK_TAG})|(?<=#{PAGE_BREAK_TAG})/

  # Returns true or false depending if the given string only consists of line
  # breaks.
  #
  # @param string [String] String to test.
  #
  # @return [Boolean]
  #
  def contains_only_line_breaks?(string)
    string =~ ONLY_LINE_BREAKS
  end

  # Returns true or false depending if the given string is a page break.
  #
  # @param string [String] String to test.
  #
  # @return [Boolean]
  #
  def is_page_break?(string)
    string == PAGE_BREAK_TAG
  end

  # Returns true/false if section spacing should be added to the document.
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
    current_section != sections.last && !is_page_break?(next_section)
  end

  # Returns if the template is from a new chapter or not.
  # Remembers the last asked template for future calls.
  #
  # @param template [Kotoba::Template] the current template to check.
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
