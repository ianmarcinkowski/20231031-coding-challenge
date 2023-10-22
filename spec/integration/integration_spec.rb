require_relative '../../app'

describe 'Guiding Test' do
  describe 'App' do
    let(:user_active) {
      {
        "id": 1,
        "first_name": "Tanya",
        "last_name": "Nichols",
        "email": "tanyat@example.com",
        "company_id": 1,
        "email_status": true,
        "active_status": true,
        "tokens": 111,
      }
    }

    let(:user_inactive) {
      {
        "id": 1,
        "first_name": "Sam",
        "last_name": "S",
        "email": "sams@example.com",
        "company_id": 1,
        "email_status": false,
        "active_status": false,
        "tokens": 111,
      }
    }
    let(:company) {
      {
        "id": 1,
        "name": "Blue Cat Inc.",
        "top_up": 71,
        "email_status": false
      }
    }
    it 'creates text output for a company and user' do
      users = [user_active]
      companies = [company]

      text = app(companies, users)

      expect(text).not_to be_nil
      expect(text).to include("Company Id: 1")
      expect(text).to include("Company Name: Blue Cat Inc.")
      expect(text).to include("Nichols, Tanya, tanyat@example.com")
      expect(text).to include("Previous Token Balance, 111")
      expect(text).to include("New Token Balance 182")
      expect(text).to include("Total amount of top ups for Blue Cat Inc.: 71")
    end

    it 'separates emailed and not-emailed users' do
      users = [user_active, user_inactive]
      companies = [company]

      text = app(companies, users)

      expect(text).not_to be_nil
      expect(text).to include(<<~TEXT)
        Users Emailed:
          Nichols, Tanya, tanyat@example.com
      TEXT
      expect(text).to include(<<~TEXT)
        Users Not Emailed:
          S, Sam, sams@example.com
      TEXT
    end
  end
end
