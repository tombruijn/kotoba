module Kotoba
  module Export
    class Base
      attr_accessor :file, :filename, :extension

      # Finds any exporter class registered under Kotoba::Export and returns it.
      #
      # @param exporter_name [String] Name of the exporter.
      # @return [Kotoba::Exporter::Base] sub clas.
      #
      # @example
      #   Kotoba::Export::Base.get("Pdf") # => Kotoba::Export::Pdf
      #
      def self.get(exporter_name)
        scope = Kotoba::Export
        scope.const_get(exporter_name.to_s.capitalize)
      end

      def initialize
        yield(self) if block_given?
      end

      # Exports the project with every configured exporter.
      # It will first check the configuration requirements and prepare the
      # build directory.
      #
      def self.export
        Kotoba.config.check_requirements
        prepare_build_directory
        Kotoba.config.exporters.each do |exporter|
          exporter.export
        end
      end

      # Creates the build directory if it doesn't exist.
      #
      def self.prepare_build_directory
        Dir.mkdir(Kotoba::BUILD_DIR) unless Dir.exists?(Kotoba::BUILD_DIR)
      end

      # Returns the filename that was configured by the user. No extension,
      # no output path should be present.
      #
      # @return [String] Filename of the to be exported file.
      #
      def filename
        @filename ||= Kotoba.config.filename
      end

      # Returns the filename that was configured by the user with the extension
      # provided by the exporter class if any is set.
      # No output path should be present.
      #
      # @return [String] Filename of the to be exported file.
      #
      def filename_with_extension
        string = filename.dup
        string << ".#{extension}" if extension
        string
      end

      # Returns the complete filepath and filename for the export.
      #
      # @return [String]
      #
      def file
        @file ||= File.join(BUILD_DIR, filename_with_extension)
      end

      # Deletes the file in the build directory if it exists.
      #
      # @see Ruby's File class' delete method.
      # @raise [Exception] on any error.
      #
      def delete
        if File.exists? file
          File.delete file
        end
      end
    end
  end
end
