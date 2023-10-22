require_relative '../../app'

describe 'Guiding Test' do
  describe 'App' do
    it 'returns a text entry for a company and user' do
      users = [{
         :id => 1,
         :first_name => "Tanya",
         :last_name => "Nichols",
         :email => "tanya.nichols@test.com",
         :company_id => 1,
         :email_status => true,
         :active_status => true,
         :tokens => 23
      }]
      companies = [{
         :id => 1,
         :name => "Blue Cat Inc.",
         :top_up => 71,
         :email_status => false
      }]

      text = app(companies, users)

      expect(text).not_to be_nil
      expect(text).to include("Company Id: 1")
      expect(text).to include("Company Name: Blue Cat Inc.")
      expect(text).to include("Nichols, Tanya, tanya.nichols@test.com")
      expect(text).to include("Previous Token Balance, 23")
      expect(text).to include("New Token Balance 94")
      expect(text).to include("Total amount of top ups for Blue Cat Inc.: 71")
    end
  end
end
