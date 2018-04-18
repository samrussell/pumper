class Bitstream
  BITS_PER_BYTE = 8
  BIT_CONVERSION_MASKS_AND_SHIFTS = [
    { mask: 0x01, shift: 0},
    { mask: 0x02, shift: 1},
    { mask: 0x04, shift: 2},
    { mask: 0x08, shift: 3},
    { mask: 0x10, shift: 4},
    { mask: 0x20, shift: 5},
    { mask: 0x40, shift: 6},
    { mask: 0x80, shift: 7},
  ]

  attr_reader :file

  def initialize(file)
    @file = file
    @bit_buffer = []
  end

  def reset
    @file.seek(0)
    @bit_buffer = []
  end

  def read(num_bits)
    top_up_buffer(num_bits) if num_bits > @bit_buffer.size

    bits = @bit_buffer.shift(num_bits)
  end

  def read_number(num_bits)
    bits_to_number(read(num_bits))
  end

  def write(bits)
    bits.each do |bit|
      @bit_buffer.push(bit)

      if @bit_buffer.length == 8
        @file.write(bits_to_byte(@bit_buffer.shift(8)).chr)
      end
    end
  end

  def flush
    @file.write(bits_to_byte(@bit_buffer).chr)
  end

  private

  def bits_to_number(bits)
    shifts = (0...bits.size).to_a
    bits.zip(shifts).map do |bit, shift|
      bit << shift
    end.reduce(0, :+)
  end

  def top_up_buffer(num_bits)
    num_extra_bits = num_bits - @bit_buffer.size
    num_extra_bytes = num_extra_bits / BITS_PER_BYTE
    num_extra_bytes += 1 if (num_extra_bits % BITS_PER_BYTE) > 0
    bytes = @file.read(num_extra_bytes)

    bytes.bytes.each do |byte|
      @bit_buffer += byte_to_bits(byte)
    end
  end

  def byte_to_bits(byte)
    BIT_CONVERSION_MASKS_AND_SHIFTS.map { |masks_and_shifts| (byte & masks_and_shifts[:mask]) >> masks_and_shifts[:shift] }
  end

  def bits_to_byte(bits)
    bits_to_number(bits)
  end
end