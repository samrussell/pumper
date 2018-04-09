require "./lib/huffman_table.rb"
require "./lib/code_length_decoder.rb"
require "./lib/bitstream.rb"

describe CodeLengthDecoder do
  let(:code_length_table) { instance_double(HuffmanTable) }
  let(:bitstream) { Bitstream.new(nil) }
  let(:code_length_decoder) { CodeLengthDecoder.new(bitstream, code_length_table) }

  describe "#decode" do
    context "small example with literals" do
      it "decodes correctly" do
        allow(code_length_table).to receive(:decode).and_return(0, 1, 2, 3, 15, 14, 13, 12)
        expect(code_length_decoder.decode(8)).to eq([nil, 1, 2, 3, 15, 14, 13, 12])
      end
    end

    context "bigger example with repeats" do
      it "decodes correctly" do
        allow(bitstream).to receive(:read).with(2).and_return([1, 1])
        allow(bitstream).to receive(:read).with(3).and_return([1, 1, 0])
        allow(bitstream).to receive(:read).with(7).and_return([0, 0, 0, 0, 0, 0, 0])
        allow(code_length_table).to receive(:decode).and_return(3, 16, 17, 2, 18, 5)
        expect(code_length_decoder.decode(26)).to eq(
          [
            3,
            3, 3, 3, 3, 3, 3,
            nil, nil, nil, nil, nil, nil,
            2,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            5])
      end
    end
  end
end