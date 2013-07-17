require "yaml"

module Kotoba
  class Parser
    attr_reader :files

    def files
      @files ||=
        Dir.glob(File.join(Kotoba::BOOK_DIR, "chapters", "**", "*"))
          .select { |file| File.file?(file) }
    end

    def collect
      files.map do |file|
        create_template(file)
      end
    end

    def create_template(file_path)
      source = read_file(file_path)
      Template.new(file_path, source)
    end

    def read_file(file_path)
      encoding = Kotoba.config.encoding
      File.read(file_path).force_encoding(encoding)
    end
  end
end
