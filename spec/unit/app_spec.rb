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
  let(:user_one) {
    {
      "id": 5,
      "company_id": 1,
      "name": "Tanya T"
    }
  }
  let(:user_two) {
    {
      "id": 99,
      "company_id": 1,
      "name": "Majid M"
    }
  }
  describe 'create_index' do
    it 'adds user to company' do
      companies = [
        company_acme
      ]
      users = [
        user_one
      ]

      index = create_index(companies, users)
      expect(index[1]).to include(
                            {
                              :id => 1,
                              :name => "ACME inc.",
                              :users => [
                                {
                                  :id => 5,
                                  :company_id => 1,
                                  :name => "Tanya T"
                                }
                              ]
                            })
    end

    it 'adds multiple users to company' do
      companies = [
        company_acme
      ]
      users = [
        user_one,
        user_two
      ]

      index = create_index(companies, users)
      company_users = index[1][:users]
      expect(company_users.size).to eq(2)
    end
  end

  describe 'build_company_report' do
    describe 'header'
    it 'contains company details' do
      company_acme[:users] = [
        user_one
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
        user_one
      ]

      report = build_company_report(company_acme)
      expect(report).to match <<~FILE.chomp
        Company Id: 1
        Company Name: ACME inc.
      FILE

    end
  end
end
