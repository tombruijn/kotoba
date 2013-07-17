module Kotoba
  class Config
    REQUIRED_CONFIG = [:filename].freeze

    attr_accessor :filename, :encoding, :title, :authors, :subject, :keywords,
                  :creator, :producer, :support_sections, :chapter_on_new_page
    attr_reader   :exporters, :layout_for

    def initialize
      @title = ""
      @authors = []
      @subject = ""
      @keywords = ""
      @creator = ""
      @producer = "Kotoba"

      @support_sections = true
      @chapter_on_new_page = true

      @encoding = "UTF-8"
      @filename = ""
      @exporters = []
      @layout_for = Hash.new { |hash, key| hash[key] = Layout.new(page_range: key)}
    end

    def layout
      yield(layout_for) if block_given?
      layout_for
    end

    def layout_for(page_range = :all)
      yield(@layout_for[page_range]) if block_given?
      @layout_for[page_range]
    end

    def layout_key_for_page(page_number)
      @layout_for.each_key do |key|
        return key if Array(key).include?(page_number)
      end
      return :all
    end

    def layout_for_page(page_number)
      page_range = layout_key_for_page(page_number)
      @layout_for[page_range]
    end

    def load(config_file = nil)
      config_file ||= File.join(APP_DIR, "config.rb")
      if File.exists? config_file
        require config_file
        check_requirements
      else
        raise "Could not find config.rb file in directory: #{APP_DIR}"
      end
    end

    def export_to(export_type, &block)
      exporter = Kotoba::Export::Base.get(export_type).new(&block)
      exporter.setup if exporter.respond_to?(:setup)
      @exporters << exporter
    end

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

    def to_h
      hash = { :CreationDate => Time.now }
      hash[:Title] = title if title
      hash[:Author] = authors.join(", ") unless authors.empty?
      hash[:Subject] = subject if subject
      hash[:Keywords] = keywords if keywords
      hash[:Creator] = creator if creator
      hash[:Producer] = producer if producer
      layout.to_h.merge(:info => hash)
    end

    protected

    def valid_key(key)
      !(self.send(key).nil? || self.send(key).empty? || self.send(key).nil?)
    end
  end
end
