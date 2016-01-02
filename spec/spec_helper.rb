if ENV["COV"]
  require "simplecov"
  SimpleCov.start do
    add_filter "spec"
  end
end

$TESTING = true

require "rspec"
require "pry"
require "kotoba"
require "kotoba/cli"
require "fileutils"
require "pdf/reader"
require "pdf/inspector"
require "support/helpers/pdf_helper"

TMP_DIR = File.join(Kotoba::LIB_DIR, "spec", "tmp")

module Kotoba
  def self.remove_paths!
    remove_const(:APP_DIR)
    remove_const(:BOOK_DIR)
    remove_const(:CHAPTERS_DIR)
    remove_const(:ASSETS_DIR)
    remove_const(:BUILD_DIR)
  end

  def self.set_original_constant_values!
    @APP_DIR ||= APP_DIR
    @BOOK_DIR ||= BOOK_DIR
    @CHAPTERS_DIR ||= CHAPTERS_DIR
    @ASSETS_DIR ||= ASSETS_DIR
    @BUILD_DIR ||= BUILD_DIR
    remove_paths!
    self.const_set(:APP_DIR, @APP_DIR)
    self.const_set(:BOOK_DIR, @BOOK_DIR)
    self.const_set(:CHAPTERS_DIR, @CHAPTERS_DIR)
    self.const_set(:ASSETS_DIR, @ASSETS_DIR)
    self.const_set(:BUILD_DIR, @BUILD_DIR)
  end

  def self.set_spec_paths!
    remove_paths!
    self.const_set(:APP_DIR, Pathname.new(File.join(LIB_DIR, "spec",
      "support", "project")))
    self.const_set(:BOOK_DIR, File.join(APP_DIR, "book"))
    self.const_set(:CHAPTERS_DIR, File.join(BOOK_DIR, "chapters"))
    self.const_set(:ASSETS_DIR, File.join(BOOK_DIR, "assets"))
    self.const_set(:BUILD_DIR, File.join(TMP_DIR, "build"))
  end

  class << self
    def clear_config!
      Kotoba.configuration = nil
    end
  end
end

RSpec.configure do |config|
  config.before(:all) do
    Kotoba.set_original_constant_values!
    Kotoba.set_spec_paths! unless self.class.description == "Kotoba"
    Kotoba.clear_config!
  end
end

def set_default_config
  Kotoba.config do |c|
    c.add_font "LiberationSerif",
      normal: "LiberationSerif-Regular.ttf",
      italic: "LiberationSerif-Italic.ttf",
      bold: "LiberationSerif-Bold.ttf",
      bold_italic: "LiberationSerif-BoldItalic.ttf"

    c.layout do |l|
      l.width = 10.cm
      l.height = 20.cm
      l.margin do |m|
        m.top = 1.cm
        m.bottom = 2.cm
        m.outer = 3.cm
        m.inner = 4.cm
      end

      l.default do |d|
        d.font = "LiberationSerif"
      end
    end
  end
end

def clear_tmp_directory
  FileUtils.rm_r(TMP_DIR) if Dir.exists?(TMP_DIR)
  Dir.mkdir(TMP_DIR)
end

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end

  result
end
