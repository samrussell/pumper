require "./lib/build_huffman_table.rb"

describe BuildHuffmanTable do
  describe "#build" do
    let(:huffman_table) { BuildHuffmanTable.new(symbol_counts).build }

    context "with even counts" do
      let(:symbol_counts) { [100, 100, 100, 100, 100, 100, 100, 100] }

      let(:expected_codeword_lengths) { [3, 3, 3, 3, 3, 3, 3, 3] }

      it "builds a huffman tree with the right code lengths" do
        expect(huffman_table.codeword_lengths).to eq(expected_codeword_lengths)
      end
    end

    context "with uneven counts" do
      # sample from the RFC
      let(:symbol_counts) { [2, 4, 1, 1] }

      let(:expected_codeword_lengths) { [2, 1, 3, 3] }

      it "builds a huffman tree with the right code lengths" do
        expect(huffman_table.codeword_lengths).to eq(expected_codeword_lengths)
      end
    end

    context "with some zero counts" do
      # sample from the RFC
      let(:symbol_counts) { [0, 2, 4, 0, 0, 1, 1] }

      let(:expected_codeword_lengths) { [0, 2, 1, 0, 0, 3, 3] }

      it "builds a huffman tree with the right code lengths" do
        expect(huffman_table.codeword_lengths).to eq(expected_codeword_lengths)
      end
    end
  end
end