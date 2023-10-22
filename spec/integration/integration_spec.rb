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

    context "sorting" do
      let(:company99) {
        {
          "id": 99,
          "name": "New Hip Co.",
          "top_up": 99,
          "email_status": true
        }
      }
      let(:user_z) {
        {
          "id": 10,
          "first_name": "Zee",
          "last_name": "Zebra",
          "email": "zebra@example.com",
          "company_id": 1,
          "email_status": true,
          "active_status": true,
          "tokens": 111,
        }
      }
      let(:user_sb) {
        {
          "id": 11,
          "first_name": "Bacon",
          "last_name": "Super",
          "email": "sb@example.com",
          "company_id": 1,
          "email_status": true,
          "active_status": true,
          "tokens": 111,
        }
      }
      let(:user_sa) {
        {
          "id": 12,
          "first_name": "Aardvark",
          "last_name": "Super",
          "email": "sa@example.com",
          "company_id": 1,
          "email_status": true,
          "active_status": true,
          "tokens": 111,
        }
      }

      it 'sorts by company ID' do
        users = []
        companies = [company99, company]

        text = app(companies, users)

        expect(text).not_to be_nil
        company_one_idx = text.index("Company Id: 1")
        company_ninty_nine_idx = text.index("Company Id: 99")
        expect(company_one_idx).to be < company_ninty_nine_idx
      end

      it 'sorts by user last, first name' do
        users = [user_z, user_sb, user_sa]
        companies = [company]

        text = app(companies, users)

        expect(text).not_to be_nil
        sa_index = text.index("Super, Aardvark, sa@example.com")
        sb_index = text.index("Super, Bacon, sb@example.com")
        z_index = text.index("Zebra, Zee, zebra@example.com")
        expect(sa_index).to be < sb_index
        expect(sb_index).to be < z_index
      end
    end
  end
end
