module Kotoba
  class Template
    YAML_METADATA = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m.freeze
    SECTION_SEPERATOR = /\n\n\n/.freeze

    attr_reader :file, :metadata, :source, :sections, :content

    def initialize(file, source)
      @file = file
      @metadata = {}
      @source = source
      @sections = []
      extract_metadata
      find_sections
    end

    def extract_metadata
      YAML_METADATA.match(source) do |match|
        @metadata = YAML.load(match[0])
        @source = source.gsub(YAML_METADATA, "")
      end
    end

    def find_sections
      @sections = source.split(SECTION_SEPERATOR)
    end
  end
end
