Kotoba.config do |config|
  # Book
  config.title = "My book"
  config.authors = ["John Doe"]

  # Export
  config.filename = "my-loaded-book"
  config.export_to :pdf
  config.export_to :text
end
