# frozen_string_literal: true
require_relative '../../app'

describe 'App' do
  let(:company_acme) {
    {
      "id": 1,
      "name": "ACME inc.",
      "token": 123
    }
  }
  let(:user_tanya) {
    {
      "id": 5,
      "company_id": 1,
      "first_name": "Tanya",
      "last_name": "T",
      "email": "tanyat@example.com",
      "tokens": 99,
      "active_status": true,
      "email_status": true
    }
  }
  let(:user_majid) {
    {
      "id": 99,
      "company_id": 1,
      "first_name": "Majid",
      "last_name": "M",
      "email": "majidm@example.com",
      "tokens": 0,
      "active_status": true,
      "email_status": true
    }
  }
  describe 'symbolize_keys' do
    it 'converts hash keys from strings to symbols' do
      string_keyed_hash = {
        "foo" => 1,
      }
      symbolized_hash = symbolize_keys(string_keyed_hash)
      expect(symbolized_hash[:foo]).to eq(1)
    end

    it 'keeps symbolized keys' do
      string_keyed_hash = {
        :wow => 99
      }
      symbolized_hash = symbolize_keys(string_keyed_hash)
      expect(symbolized_hash[:wow]).to eq(99)
    end
    it 'keeps symbolized keys' do
      string_keyed_hash = {
        :wow => 99
      }
      symbolized_hash = symbolize_keys(string_keyed_hash)
      expect(symbolized_hash[:wow]).to eq(99)
    end
  end

  describe 'build_database' do
    it 'adds user to company' do
      companies = [
        company_acme
      ]
      users = [
        user_tanya
      ]

      database = build_database(companies, users)
      _, company = database[0]
      expect(company).to include({
                                   :id => 1,
                                   :name => "ACME inc.",
                                 })
      expect(company[:users].first).to include(
                                   {
                                     :id => 5,
                                     :company_id => 1,
                                     :first_name => "Tanya",
                                     :last_name => "T",
                                     :email => "tanyat@example.com"
                                   }
                                 )
    end

    it 'adds multiple users to company' do
      companies = [
        company_acme
      ]
      users = [
        user_tanya,
        user_majid
      ]

      database = build_database(companies, users)
      _, company = database[0]
      expect(company[:users].size).to eq(2)
    end
  end

  describe 'build_company_report' do
    describe 'header'
    it 'contains company details' do
      company_acme[:users] = [
        user_tanya
      ]

      report = build_company_report(company_acme)
      expect(report).to match <<~FILE.chomp
        Company Id: 1
        Company Name: ACME inc.
      FILE
    end

    describe 'users'
    it 'contains company details' do
      company_acme[:users] = [
        user_tanya
      ]

      report = build_company_report(company_acme)
      expect(report).to match <<~FILE.chomp
        Company Id: 1
        Company Name: ACME inc.
      FILE
    end

    context 'when company email is disabled' do
      it 'does not send emails for any users' do
        company_acme[:email_status] = false
        company_acme[:users] = [
          user_tanya
        ]

        report = build_company_report(company_acme)
        expect(report).to include(<<~TEXT)
          Users Not Emailed:
          T, Tanya, tanyat@example.com
        TEXT
      end
    end
  end

  describe 'build_user_report' do
    let(:user) {
      {
        :id => 12,
        :first_name => "Ian",
        :last_name => "M",
        :email => "ian@desrt.ca",
        :tokens => 999,
        :token_history => [100, 50, 10]
      }
    }
    describe 'users'
    it 'contains user details' do
      report = build_user_report(user)
      expect(report).to match <<~FILE.chomp
        M, Ian, ian@desrt.ca
          Previous Token Balance, 100
          New Token Balance 999
      FILE
    end
  end

  describe 'process_token_top_ups!' do
    let(:company) {
      {
        :id => 1,
        :top_up => 23,
      }
    }
    let(:active_user) {
      {
        :id => 99,
        :company_id => 1,
        :tokens => 100,
        :active_status => true
      }
    }
    it 'adds tokens for active users' do
      database = build_database(
        [company],
        [active_user]
      )
      report = process_token_top_ups!(database)
      _, company = database[0]
      expect(company[:users].first).to include({ :tokens => 123 })
    end

    it 'tracks top ups given' do
      database = build_database(
        [company],
        [active_user]
      )
      report = process_token_top_ups!(database)
      _, company = database[0]
      expect(company[:top_ups_given]).to eq(23)
    end
  end

  describe 'update_user_tokens!' do
    let(:user) {
      {
        :tokens => 0,
      }
    }
    it 'creates token history' do
      update_user_tokens!(user, 11)
      expect(user[:token_history].first).to eq(0)
    end

    it 'preserves token history' do
      user[:token_history] = [100, 50, 0]
      update_user_tokens!(user, 1)
      expect(user[:token_history].size).to eq(4)
    end

    it 'adds tokens' do
      update_user_tokens!(user, 99)
      expect(user[:tokens]).to eq(99)
    end
  end
end
