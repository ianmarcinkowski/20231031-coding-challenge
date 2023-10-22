# frozen_string_literal: true
require_relative '../../app'

company_acme = {
    "id": 1,
    "name": "ACME inc."
  }
user_one = {
  "id": 5,
  "company_id": 1,
  "name": "Tanya T"
}
user_two = {
    "id": 99,
    "company_id": 1,
    "name": "Majid M"
  }

describe 'App' do
  describe 'indexing' do
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
end
