module Kotoba
  class Asset
    # Returns the path of an asset.
    #
    # @return [String] path of given asset.
    #
    def asset_path(filename)
      File.join(Kotoba::ASSETS_DIR, filename)
    end
  end
end

require "kotoba/font"
