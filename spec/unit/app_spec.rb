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
      "previous_tokens": 54,
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
      "previous_tokens": 1000,
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
      expect(database[1]).to include({
                                       :id => 1,
                                       :name => "ACME inc.",
                                       :users => [
                                         {
                                           :id => 5,
                                           :company_id => 1,
                                           :first_name => "Tanya",
                                           :last_name => "T",
                                           :email => "tanyat@example.com"
                                         }
                                       ]
                                     })
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
      company_users = database[1][:users]
      expect(company_users.size).to eq(2)
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
  end

  describe 'build_user_report' do
    describe 'users'
    it 'contains company details' do
      report = build_user_report(user_tanya)
      expect(report).to match <<~FILE.chomp
        T, Tanya, tanyat@example.com
          Previous Token Balance, 99
          New Token Balance 54
      FILE
    end
  end

  describe 'update_user_balances' do
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
      report = update_user_balances(database)
      expect(database[1][:users].first).to include({ :tokens => 123 })
    end

    it 'tracks top ups given' do
      database = build_database(
        [company],
        [active_user]
      )
      report = update_user_balances(database)
      expect(database[1][:top_ups_given]).to eq(23)
    end
  end
end
