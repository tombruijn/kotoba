require "kotoba"
require "thor"

module Kotoba
  class Cli < Thor
    include Thor::Actions
    TEMPLATES_DIR = File.join(Kotoba::LIB_DIR, "support", "templates")

    def self.source_root
      TEMPLATES_DIR
    end

    desc "new", "Create a new Kotoba project"
    def new(project_name)
      @project_name = project_name
      say "Welcome to Kotoba"
      say ""
      say_status :info, "Creating project: #{project_name}"
      directory "new_project", project_name
      Dir.chdir(File.join(Dir.pwd, project_name)) do
        say_status :info, "Installing gems"
        Bundler.with_clean_env do
          say `bundle install` unless $TESTING
        end
      end
    end

    desc "export", "Export your Kotoba project"
    method_option :type, :default => :all
    def export
      Kotoba.config.load

      say "Exporting your book"

      Kotoba.export
    end
  end
end
