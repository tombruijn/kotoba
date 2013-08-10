# Renders and reads the document
#
# @param [Prawn::Document]
#
def read_document(document)
  StringIO.new(document.render, "r+")
end

# Renders the Prawn document to a PDF which is then read to extract
# details about the end result
#
# @param document [Prawn::Document]
# @return [PDF::Reader::ObjectHash] PDF as an object
#
def find_objects(document)
  string = read_document(document)
  PDF::Reader::ObjectHash.new(string)
end
