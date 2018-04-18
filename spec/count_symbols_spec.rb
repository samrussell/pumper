require "./lib/count_symbols.rb"

describe CountSymbols do
  describe "#counts" do
    let(:decoded_data) { "ABC abc abc 123".chars }
    let(:counter) { CountSymbols.new(decoded_data) }
    let(:counts) { counter.counts }

    it "Gets the symbol counts correct" do
      expect(counts['a'.ord]).to eq(2)
      expect(counts['c'.ord]).to eq(2)
      expect(counts[' '.ord]).to eq(3)
      expect(counts['A'.ord]).to eq(1)
      expect(counts.length).to eq('c'.ord + 1)
    end
  end
end