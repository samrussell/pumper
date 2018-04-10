require "./lib/bitstream"

describe Bitstream do
  let(:bytes) { "\x1E\x3C\x5A\x78\x96\xB4\xD2" }
  let(:byte_stream) { StringIO.new(bytes) }
  let(:bitstream) { Bitstream.new(byte_stream) }

  describe "#read" do
    it "returns 8 bits" do
      expect(bitstream.read(8)).to eq([0, 1, 1, 1, 1, 0, 0, 0])
      expect(bitstream.read(8)).to eq([0, 0, 1, 1, 1, 1, 0, 0])
    end

    it "returns 4 bits" do
      expect(bitstream.read(4)).to eq([0, 1, 1, 1])
      expect(bitstream.read(4)).to eq([1, 0, 0, 0])
      expect(bitstream.read(4)).to eq([0, 0, 1, 1])
      expect(bitstream.read(4)).to eq([1, 1, 0, 0])
    end

    it "overlaps nicely when getting odd numbers of bits" do
      expect(bitstream.read(3)).to eq([0, 1, 1])
      expect(bitstream.read(8)).to eq([1, 1, 0, 0, 0, 0, 0, 1])
      expect(bitstream.read(5)).to eq([1, 1, 1, 0, 0])
    end

    it "can get multiple bytes" do
      expect(bitstream.read(16)).to eq([0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0])
      expect(bitstream.read(12)).to eq([0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1])
      expect(bitstream.read(12)).to eq([1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1])
    end
  end

  describe "#read_number" do
    it "returns 8 bits" do
      expect(bitstream.read_number(8)).to eq(0b00011110)
      expect(bitstream.read_number(8)).to eq(0b00111100)
    end

    it "returns 4 bits" do
      expect(bitstream.read_number(4)).to eq(0b1110)
      expect(bitstream.read_number(4)).to eq(0b0001)
      expect(bitstream.read_number(4)).to eq(0b1100)
      expect(bitstream.read_number(4)).to eq(0b0011)
    end

    it "overlaps nicely when getting odd numbers of bits" do
      expect(bitstream.read_number(3)).to eq(0b110)
      expect(bitstream.read_number(8)).to eq(0b10000011)
      expect(bitstream.read_number(5)).to eq(0b00111)
    end

    it "can get multiple bytes" do
      expect(bitstream.read_number(16)).to eq(0b0011110000011110)
      expect(bitstream.read_number(12)).to eq(0b100001011010)
      expect(bitstream.read_number(12)).to eq(0b100101100111)
    end
  end
end