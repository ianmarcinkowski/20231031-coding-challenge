require 'json'

# Create an entrypoint to separate the concerns of running this application
# as a script from the domain logic.
def entry_point(companies_path, users_path)
  puts "companies file: #{companies_path}"
  puts "users file: #{users_path}"

  companies_file = File.open companies_path
  users_file = File.open users_path

  companies = JSON.load companies_file
  users = JSON.load users_file
  app(companies, users)
end

def app(companies, users)
  database = build_database(companies, users)
  report = ""
  database.values.map do |company|
    report += build_company_report(company)
  end
  report
end

def symbolize_keys(a_hash)
  a_hash.transform_keys(&:to_sym)
end

def build_database(companies, users)
  database = {}
  companies.map do |company|
    company = symbolize_keys(company)
    company[:users] = []
    company_id = company[:id]
    database[company_id] = company
  end
  users.map do |user|
    user = symbolize_keys(user)
    company_id = user[:company_id]
    database[company_id][:users].append user
  end
  database
end

def build_company_report(company)
  report = <<~REPORT
    Company Id: #{company[:id]}
    Company Name: #{company[:name]}
    REPORT
end
