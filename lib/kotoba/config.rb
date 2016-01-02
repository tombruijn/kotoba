module Kotoba
  class Config
    REQUIRED_CONFIG = [:filename].freeze

    attr_accessor :filename, :encoding, :title, :authors, :subject, :keywords,
                  :creator, :producer, :metadata, :support_sections,
                  :section_spacing, :chapter_on_new_page, :fonts
    attr_reader   :exporters, :layout_for

    def initialize
      @title = ""
      @authors = []
      @subject = ""
      @keywords = ""
      @creator = "Kotoba"
      @producer = "Kotoba"
      @metadata = {}
      @fonts = {}

      @support_sections = true
      @section_spacing = 5.mm
      @chapter_on_new_page = true

      @encoding = "UTF-8"
      @filename = ""
      @exporters = []
      @layout_for = Hash.new do |hash, key|
        hash[key] = Layout.new(page_range: key)
      end
    end

    # Loads a Kotoba configuration file.
    # Checks requirements and exits when the given config file is not found.
    # Exits the program when the given config file is not found.
    #
    # @param config_file [String] path to file. Defaults to APP_DIR + config.rb
    #
    def load(config_file = nil)
      config_file ||= File.join(APP_DIR, "config.rb")
      if File.exists? config_file
        require config_file
        check_requirements
      else
        puts "Could not find config.rb file in directory: #{APP_DIR}"
        exit(1)
      end
    end

    # Allows for configuration and retrieval of the default page layout.
    #
    # @see layout_for
    #
    # @yield [Kotoba::Layout] default layout object for configuration
    # @return [Kotoba::Layout] default layout object
    #
    def layout
      yield(layout_for) if block_given?
      layout_for
    end

    # Allows for configuration and retrieval of a page layout.
    # Page range should be a Range, Integer or Symbol.
    #
    # If given a block it will pass the layout object which can be used to set
    # configuration details.
    #
    # @param page_range [Object] Range, Integer or Symbol
    # @yield [Kotoba::Layout] default layout object for configuration
    # @return [Kotoba::Layout] layout object
    #
    def layout_for(page_range = :all)
      yield(@layout_for[page_range]) if block_given?
      @layout_for[page_range]
    end

    # Returns the page layout configuration for a page.
    # Used for retrieval of a layout of a specific page, no ranges or dynamic
    # selectors.
    #
    # @param page_number [Integer] Range, Integer or Symbol
    # @return [Kotoba::Layout] layout object
    #
    def layout_for_page(page_number)
      page_key = layout_key_for_page(page_number)
      @layout_for[page_key]
    end

    # Adds an exporter to the exporters list.
    # If a block is given it will pass the exporter to that block so it can be
    # configured.
    #
    # @param export_type [String/Symbol] name of the exporter
    # @yield [Kotoba::Export::Base] selected exporter for configuration
    # @return [Kotoba::Export::Base] selector exporter
    #
    def export_to(export_type, &block)
      exporter = Kotoba::Export::Base.get(export_type).new(&block)
      exporter.setup if exporter.respond_to?(:setup)
      @exporters << exporter
    end

    # Add a font to the configuration.
    # Any registered font can be used in the export of the document.
    #
    # @see Prawn's Font documentation for the already registered fonts.
    #
    # @param name [String] Name of the font as used in styling.
    # @param types [Hash] Hash containing all types of the font.
    #
    # @example
    #
    #   Kotoba.config.add_font "OpenSans", {
    #     normal: { file: "OpenSans-Regular" }
    #     italic: { file: "OpenSans-Italic" }
    #   }
    #
    def add_font(name, types)
      @fonts[name] = Font.new(name, types)
    end

    # Checks the required configuration and throws an error if it is incomplete
    #
    # @raise [Exception] exception with message of keys that are not set
    #
    def check_requirements
      invalid_keys = []
      REQUIRED_CONFIG.each do |key|
        unless valid_key(key)
          invalid_keys << key
        end
      end
      if invalid_keys.any?
        raise "Configuration keys \"#{invalid_keys.join(", ")}\" are not set."
      end
    end

    # Returns a hash with metadata that will be set in the PDF by Prawn.
    #
    # @todo Bug for producer key? Have to set it twice?
    # @return [Hash] Hash with prawn metadata
    #
    def to_h
      hash = metadata.merge(:CreationDate => Time.now)
      hash[:Title] = title if title
      hash[:Author] = authors.join(", ") unless authors.empty?
      hash[:Subject] = subject if subject
      hash[:Keywords] = keywords if keywords
      hash[:Creator] = creator if creator
      if producer
        hash[:Producer] = producer
        hash["Producer"] = producer
      end
      {:info => hash}
    end

    protected

    # Get the key used to define the layout of the given page number.
    # If no specific layout is found it uses the default layout.
    #
    # @return [Object] selector for layout, can be a symbol, range, Integer, etc
    #
    def layout_key_for_page(page_number)
      @layout_for.each_key do |key|
        return key if Array(key).include?(page_number)
      end
      return :all
    end

    def valid_key(key)
      !(self.send(key).nil? || self.send(key).empty? || self.send(key).nil?)
    end
  end
end
