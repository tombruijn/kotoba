module Kotoba
  LIB_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..")).freeze
  BIN_DIR = File.join(LIB_DIR, "bin").freeze

  APP_DIR = Pathname.new(Dir.pwd).freeze
  BOOK_DIR = File.join(APP_DIR, "book").freeze
  CHAPTERS_DIR = File.join(BOOK_DIR, "chapters").freeze
  ASSETS_DIR = File.join(BOOK_DIR, "assets").freeze
  BUILD_DIR = File.join(APP_DIR, "build").freeze

  class << self
    attr_accessor :configuration, :book

    def book
      @book ||= Book.new
    end

    def config
      @configuration ||= Config.new
      yield(@configuration) if block_given?
      @configuration
    end

    def export
      Kotoba::Export::Base.export
    end
  end
end

require "hashie"
require "prawn"
require "prawn/measurement_extensions"
require "kotoba/version"
require "kotoba/asset"
require "kotoba/config"
require "kotoba/layout"
require "kotoba/content"
require "kotoba/formatting"
require "kotoba/parser"
require "kotoba/template"
require "kotoba/book"
require "kotoba/outline"
require "kotoba/export/base"
