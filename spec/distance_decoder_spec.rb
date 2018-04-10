require "./lib/distance_decoder.rb"
require "./lib/bitstream.rb"

describe DistanceDecoder do
  describe "#decode" do
    let(:bitstream) { Bitstream.new(nil) }
    let(:distance_decoder) { DistanceDecoder.new(bitstream) }

    it "decodes the simple ones (no extra bits)" do
      expect(distance_decoder.decode(0)).to eq(1)
      expect(distance_decoder.decode(3)).to eq(4)
    end

    it "decodes more complex ones (a range of extra bits)" do
      allow(bitstream).to receive(:read).and_return(
        [0, 0], [0, 0, 1, 0, 0, 1], [1, 1, 1, 1, 1, 1, 0, 1, 1], [1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1]
      )
      allow(bitstream).to receive(:read_bits).and_call_original
      expect(distance_decoder.decode(7)).to eq(13)
      expect(distance_decoder.decode(14)).to eq(165)
      expect(distance_decoder.decode(21)).to eq(1984)
      expect(distance_decoder.decode(29)).to eq(29876)
    end
  end
end