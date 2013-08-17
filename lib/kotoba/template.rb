module Kotoba
  class Template
    YAML_METADATA = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m.freeze
    SECTION_SEPERATOR = /\n\n\n/.freeze
    PAGE_BREAK_TAG = "\n___PAGE___\n"
    # Split on ___PAGE___ but keep the key
    PAGE_BREAK_SPLITTER = /(?=#{PAGE_BREAK_TAG})|(?<=#{PAGE_BREAK_TAG})/

    attr_reader :file, :metadata, :content

    def initialize(file, content)
      @file = file
      @metadata = {}
      @content = content
      extract_metadata
    end

    def extract_metadata
      YAML_METADATA.match(content) do |match|
        @metadata = YAML.load(match[0])
        @content = content.gsub(YAML_METADATA, "")
      end
    end

    # Returns an array of the template's content.
    # When support_sections is on it will split up the content on
    # SECTION_SEPARATOR.
    # Every ___PAGE___ alone on a line should be treated as a new page.
    #
    # @return [Array] array of sections and page breaks
    #
    def source
      strings = self.content.split(PAGE_BREAK_SPLITTER)
      if Kotoba.config.support_sections
        strings.collect! { |string| string.split(SECTION_SEPERATOR) }
      end
      strings.flatten
    end
  end
end
