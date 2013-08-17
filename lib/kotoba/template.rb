module Kotoba
  class Template
    YAML_METADATA = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m.freeze
    SECTION_SEPERATOR = /\n\n\n/.freeze

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

    def source
      strings = [self.content]
      if Kotoba.config.support_sections
        strings.collect! { |string| string.split(SECTION_SEPERATOR) }
      end
      strings.flatten
    end
  end
end
