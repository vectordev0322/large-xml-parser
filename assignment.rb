require 'nokogiri'
require 'json'

class ProductParser < Nokogiri::XML::SAX::Document
  ONE_MEGA_BYTE = 1_048_576.0
  MAX_BATCH_SIZE = 5 * ONE_MEGA_BYTE

  def initialize
    @current_element = ""
    @product = {}
    @batch = []
    @current_batch_size = 0
    @external_service = ExternalService.new
  end

  # Called when the parser encounters the start of an element
  def start_element(name, attributes = [])
    @current_element = name
    @product = {} if name == 'item' # Prepare to parse a new product
  end

  # Called when the parser encounters content within tags
  def characters(content)
    case @current_element
    when 'g:id'
      @product[:id] = content.strip
    when 'title'
      @product[:title] = content.strip
    when 'description'
      @product[:description] = content.strip
    end
  end

  # Called when the parser encounters the end of an element
  def end_element(name)
    if name == 'item' # A complete product is read
      add_to_batch(@product)
      @product = {}
    end
  end

  # Add a product to the batch and check size
  def add_to_batch(product)
    product_json = product.to_json
    product_size = product_json.bytesize

    # If adding this product exceeds batch size, flush current batch
    if @current_batch_size + product_size > MAX_BATCH_SIZE
      flush_batch
    end

    @batch << product
    @current_batch_size += product_size
  end

  # Flush the batch to the external service
  def flush_batch
    @external_service.call(@batch.to_json) unless @batch.empty?
    @batch.clear
    @current_batch_size = 0
  end

  # Called at the end of the document to flush any remaining batched data
  def end_document
    flush_batch
  end
end

# Simulates the external service
class ExternalService
  ONE_MEGA_BYTE = 1_048_576.0

  def initialize
    @batch_num = 0
  end

  def call(batch)
    @batch_num += 1
    pretty_print(batch)
  end

  private

  def pretty_print(batch)
    products = JSON.parse(batch)
    puts format("\e[1mReceived batch%4d\e[22m", @batch_num)
    puts format('Size: %10.2fMB', (batch.bytesize / ONE_MEGA_BYTE))
    puts format('Products: %8d', products.size)
    puts "\n"
  end
end

# Process large XML files using SAX parsing
xml_file = 'feed.xml'
parser = Nokogiri::XML::SAX::Parser.new(ProductParser.new)
File.open(xml_file) do |file|
  parser.parse(file) # Stream and parse the file incrementally
end