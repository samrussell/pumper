class Uncover
  FLAG_FILENAME = 0x08

  def initialize(input_file)
    @input_file = input_file
  end

  def block()
    # skip over the header
    read_header
    # return file handle at the start of the data block
    @input_file
  end

  private

  def read_header()
    serialised_header = @input_file.read(4)
    magic_bytes, compression_mode, flags, modified_time, extra_flags, operating_system = serialised_header.unpack("S>CCI>CC")
    raise "Bad magic words" unless magic_bytes == 0x1F8B
    raise "Bad compression" unless compression_mode == 8
    raise "Bad flags" unless (flags & (0xFF ^ FLAG_FILENAME)) == 0
    skip_filename if (flags & FLAG_FILENAME) != 0
  end

  def skip_filename
    while true
      break if @input_file.read(1).ord == 0
    end
  end
end