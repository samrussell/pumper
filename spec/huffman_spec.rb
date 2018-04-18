require "./lib/build_huffman_table.rb"
require "./lib/huffman_table.rb"
require "./lib/count_symbols.rb"
require "./lib/bitstream.rb"

describe "Huffman encoder/decoders" do 
  let(:decoded_data) do
    ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed " +
    "do eiusmod tempor incididunt ut labore et dolore magna aliqua. " +
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris " +
    "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in " +
    "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " +
    "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " +
    "culpa qui officia deserunt mollit anim id est laborum.\n").chars.map(&:ord)
  end

  let(:symbol_counts) { CountSymbols.new(decoded_data).counts }
  let(:codeword_lengths) { BuildHuffmanTable.new(symbol_counts).build.codeword_lengths }
  let(:huffman_table) { HuffmanTable.new(codeword_lengths) }
  let(:byte_stream) { StringIO.new }
  let(:bitstream) { Bitstream.new(byte_stream) }

  before do
    huffman_table.encode(decoded_data, bitstream)
    bitstream.reset
    @actual_decoded_data = decoded_data.length.times.map { huffman_table.decode(bitstream) }
  end

  it "encodes and then decodes correctly" do
    expect(@actual_decoded_data).to eq(decoded_data)
  end
end