class DistanceDecoder
  def initialize(bitstream)
    @bitstream = bitstream
  end

  def decode(symbol)
    if 0 <= symbol && symbol <= 3
      1 + symbol
    elsif 4 <= symbol && symbol <= 5
      5 + ((symbol - 4) << 1) + @bitstream.bits_to_number(@bitstream.read(1))
    elsif 6 <= symbol && symbol <= 7
      9 + ((symbol - 6) << 2) + @bitstream.bits_to_number(@bitstream.read(2))
    elsif 8 <= symbol && symbol <= 9
      17 + ((symbol - 8) << 3) + @bitstream.bits_to_number(@bitstream.read(3))
    elsif 10 <= symbol && symbol <= 11
      33 + ((symbol - 10) << 4) + @bitstream.bits_to_number(@bitstream.read(4))
    elsif 12 <= symbol && symbol <= 13
      65 + ((symbol - 12) << 5) + @bitstream.bits_to_number(@bitstream.read(5))
    elsif 14 <= symbol && symbol <= 15
      129 + ((symbol - 14) << 6) + @bitstream.bits_to_number(@bitstream.read(6))
    elsif 16 <= symbol && symbol <= 17
      257 + ((symbol - 16) << 7) + @bitstream.bits_to_number(@bitstream.read(7))
    elsif 18 <= symbol && symbol <= 19
      513 + ((symbol - 18) << 8) + @bitstream.bits_to_number(@bitstream.read(8))
    elsif 20 <= symbol && symbol <= 21
      1025 + ((symbol - 20) << 9) + @bitstream.bits_to_number(@bitstream.read(9))
    elsif 22 <= symbol && symbol <= 23
      2049 + ((symbol - 22) << 10) + @bitstream.bits_to_number(@bitstream.read(10))
    elsif 24 <= symbol && symbol <= 25
      4097 + ((symbol - 24) << 11) + @bitstream.bits_to_number(@bitstream.read(11))
    elsif 26 <= symbol && symbol <= 27
      8193 + ((symbol - 26) << 12) + @bitstream.bits_to_number(@bitstream.read(12))
    elsif 28 <= symbol && symbol <= 29
      16385 + ((symbol - 28) << 13) + @bitstream.bits_to_number(@bitstream.read(13))
    else
      raise "Can't handle length symbol #{symbol}"
    end
  end
end