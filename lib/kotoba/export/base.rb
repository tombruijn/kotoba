module Kotoba
  module Export
    class Base
      attr_accessor :file, :filename, :extension

      def self.get(exporter_name)
        scope = Kotoba::Export
        scope.const_get(exporter_name.to_s.capitalize)
      end

      def initialize
        yield(self) if block_given?
      end

      def self.export
        Kotoba.config.check_requirements
        prepare_build_directory
        Kotoba.config.exporters.each do |exporter|
          exporter.export
        end
      end

      def self.prepare_build_directory
        Dir.mkdir(Kotoba::BUILD_DIR) unless Dir.exists?(Kotoba::BUILD_DIR)
      end

      def filename
        @filename ||= Kotoba.config.filename
      end

      def filename_with_extension
        string = filename.dup
        string << ".#{extension}" if extension
        string
      end

      def file
        @file ||= File.join(BUILD_DIR, filename_with_extension)
      end

      def delete
        if File.exists? file
          begin
            File.delete file
          rescue e
            puts "Could not delete file:"
            puts e.inspect
          end
        end
      end

      def config
        Kotoba.config
      end
    end
  end
end
