require "./lib/length_decoder.rb"
require "./lib/bitstream.rb"

describe LengthDecoder do
  describe "#decode" do
    let(:bitstream) { Bitstream.new(nil) }
    let(:length_decoder) { LengthDecoder.new(bitstream) }

    it "decodes the simple ones (no extra bits)" do
      expect(length_decoder.decode(257)).to eq(3)
      expect(length_decoder.decode(264)).to eq(10)
    end

    it "decodes more complex ones (a range of extra bits)" do
      allow(bitstream).to receive(:read).and_return([0], [0, 1], [1, 1, 0, 0, 1])
      allow(bitstream).to receive(:read_bits).and_call_original
      expect(length_decoder.decode(265)).to eq(11)
      expect(length_decoder.decode(272)).to eq(33)
      expect(length_decoder.decode(281)).to eq(150)
      expect(length_decoder.decode(285)).to eq(258)
    end
  end
end