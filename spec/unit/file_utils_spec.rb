require_relative '../../file_utils'

describe "file reading" do
    it "works" do
      path = 'spec/fixtures/example.txt'
      contents = read_file_content(path)
      expect(contents).to eq('example text file')
    end

    it "returns empty string if file not found" do
      path = 'spec/fixtures/404.txt'
      contents = read_file_content(path)
      expect(contents).to be_nil
    end
end
