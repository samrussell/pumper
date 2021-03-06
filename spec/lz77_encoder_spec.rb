require "./lib/lz77_encoder.rb"

def build_encoded_data_array(data_string)
  output = []
  data_string.each do |item|
    if item.is_a?(String)
      output += item.chars
    else
      output.push(item)
    end
  end

  output
end

describe Lz77Encoder do
  describe "#encode" do
    let(:encoder) { Lz77Encoder.new(decoded_data) }

    context "with something uncompressible" do
      let(:decoded_data) { "abc123ABCJKL".chars }
      let(:encoded_data) { "abc123ABCJKL".chars }

      it "LZ77 encodes the data with the greedy algorithm" do
        expect(encoder.encode.to_a).to eq(encoded_data)
      end
    end

    context "with a match inside a match" do
      let(:decoded_data) { "abcabcdbcde".chars }
      let(:encoded_data) { build_encoded_data_array(["abc", [3, 3], "d", [3, 3], "e"]) }

      it "LZ77 encodes the data with the greedy algorithm" do
        expect(encoder.encode.to_a).to eq(encoded_data)
      end
    end

    context "with a match at the end of the string" do
      let(:decoded_data) { "abcdeabcde".chars }
      let(:encoded_data) { build_encoded_data_array(["abcde", [5, 5]]) }

      it "LZ77 encodes the data with the greedy algorithm" do
        expect(encoder.encode.to_a).to eq(encoded_data)
      end
    end

    context "making sure we add to the match dict even if we're copying" do
      let(:decoded_data) { "abcdabceabce".chars }
      let(:encoded_data) { build_encoded_data_array(["abcd", [4, 3], "e", [4, 4]]) }

      it "LZ77 encodes the data with the greedy algorithm" do
        expect(encoder.encode.to_a).to eq(encoded_data)
      end
    end

    context "with the lorem ipsum text" do
      let(:encoded_data) do
        build_encoded_data_array([
          "Lorem ipsum dolor sit amet, consectetur adipiscing eli", [29, 3], 
          "sed", [49, 3], " eiusmod temp", [61, 3], "incididunt ut lab", [95, 3], 
          " et", [91, 6], "e magna aliqua. Ut enim", [92, 3], " mi", [9, 4], "v", [15, 3], 
          "am, quis nostrud exercitation ullamco", [90, 6], [37, 4], "isi", [106, 4], [83, 5], 
          "ip", [45, 3], " ea", [185, 3], "m", [148, 3], "o", [193, 6], [107, 3], 
          "t. D", [83, 4], "aute iru", [138, 3], [236, 6], "in reprehender", [249, 3], [17, 3], 
          "volup", [111, 3], "e", [143, 3], [234, 3], " esse cill", [290, 8], [209, 3], 
          "u fugiat n", [145, 4], " par", [13, 3], "ur. Excepte", [305, 3], "si", [260, 3], 
          "occaec", [40, 3], "cupida", [86, 3], [215, 3], "n proiden", [326, 4], [298, 4], [117, 3], 
          "culpa", [248, 4], " officia deser", [30, 4], "mol", [135, 4], "a", [289, 4], 
          "i", [271, 3], "s", [344, 7], "um.\n"])
      end

      let(:decoded_data) do
        ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed " +
        "do eiusmod tempor incididunt ut labore et dolore magna aliqua. " +
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris " +
        "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in " +
        "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " +
        "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " +
        "culpa qui officia deserunt mollit anim id est laborum.\n").chars
      end

      it "LZ77 encodes the data with the greedy algorithm" do
        actual_encoded_data = encoder.encode.to_a
        expect(actual_encoded_data).to eq(encoded_data)
      end
    end
  end
end