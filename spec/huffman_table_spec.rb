require "./lib/huffman_table.rb"

class MockBitStream
  def initialize(data)
    @data = data
  end

  def read(num_bits)
    @data.shift(num_bits)
  end
end

describe HuffmanTable do

  let(:bit_stream) { MockBitStream.new(coded_data)}
  let(:huffman_table) { HuffmanTable.new(prefix_lengths) }

  describe "#decode" do
    context "with a simple table" do
      # this gives us the simplest table
      # {
      #   0 => "0",
      #   1 => "1"
      # }
      let(:prefix_lengths) { [1, 1] }
      let(:coded_data) { [0, 1, 1, 0] }

      it "decodes a string of bits correctly" do
        expect(huffman_table.decode(bit_stream)).to eq(0)
        expect(huffman_table.decode(bit_stream)).to eq(1)
        expect(huffman_table.decode(bit_stream)).to eq(1)
        expect(huffman_table.decode(bit_stream)).to eq(0)
      end
    end

    context "with a semi-simple table" do
      # this gives us the second simplest table, also out of order
      # {
      #   0 => "10",
      #   1 => "0",
      #   2 => "11"
      # }
      let(:prefix_lengths) { [2, 1, 2] }
      let(:coded_data) { [0, 1, 1, 0, 1, 0] }

      it "decodes a string of bits correctly" do
        expect(huffman_table.decode(bit_stream)).to eq(1)
        expect(huffman_table.decode(bit_stream)).to eq(2)
        expect(huffman_table.decode(bit_stream)).to eq(1)
        expect(huffman_table.decode(bit_stream)).to eq(0)
      end
    end

    context "with a complicated table" do
      # this is the code length huffman code in the lorem ipsum example
      # it gives us the following code
      # {
      #   4=>"00",
      #   5=>"010",
      #   7=>"011",
      #   8=>"100",
      #   18=>"101",
      #   0=>"1100",
      #   3=>"1101",
      #   17=>"1110",
      #   2=>"11110",
      #   6=>"11111",
      # }
      let(:prefix_lengths) { [4, nil, 5, 4, 2, 3, 5, 3, 3, nil, nil, nil, nil, nil, nil, nil, nil, 4, 3] }
      let(:coded_data) { [0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0] }

      it "decodes a string of bits correctly" do
        expect(huffman_table.decode(bit_stream)).to eq(4)
        expect(huffman_table.decode(bit_stream)).to eq(18)
        expect(huffman_table.decode(bit_stream)).to eq(7)
        expect(huffman_table.decode(bit_stream)).to eq(0)
      end
    end
  end
end