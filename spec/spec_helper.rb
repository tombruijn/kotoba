if ENV["COV"]
  require "simplecov"
  SimpleCov.start do
    add_filter "spec"
  end
end

$TESTING = true

require "rspec"
require "kotoba"
require "kotoba/cli"
require "pry"
require "fileutils"
require "pdf/reader"
require "pdf/inspector"
require "support/helpers/pdf_helper"

TMP_DIR = File.join(Kotoba::LIB_DIR, "spec", "tmp")

module Kotoba
  remove_const(:APP_DIR)
  remove_const(:BOOK_DIR)
  remove_const(:VIEWS_DIR)
  remove_const(:ASSETS_DIR)
  remove_const(:BUILD_DIR)
  APP_DIR = Pathname.new(File.join(LIB_DIR, "spec", "support",
    "project")).freeze
  BOOK_DIR = File.join(APP_DIR, "book").freeze
  VIEWS_DIR = File.join(BOOK_DIR, "views").freeze
  ASSETS_DIR = File.join(BOOK_DIR, "assets").freeze
  BUILD_DIR = File.join(TMP_DIR, "build").freeze

  class << self
    def clear_config!
      Kotoba.configuration = nil
    end
  end
end

RSpec.configure do |config|
  config.before(:all) do
    Kotoba.clear_config!
  end
end

def set_default_config
  Kotoba.config do |c|
    c.layout do |l|
      l.width = 10.cm
      l.height = 20.cm
      l.margin do |m|
        m.top = 1.cm
        m.bottom = 2.cm
        m.outer = 3.cm
        m.inner = 4.cm
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
