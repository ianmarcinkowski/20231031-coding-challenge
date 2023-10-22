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
  index = create_index(companies, users)
  report = ""
  index.values.map do |company|
    report += build_company_report(company)
  end
  report
end

def create_index(companies, users)
  index = {}
  companies.map do |company|
    company[:users] = []
    company_id = company[:id]
    index[company_id] = company
  end
  users.map do |user|
    company_id = user[:company_id]
    index[company_id][:users].append user
  end
  index
end

def build_company_report(company)
  report = <<~REPORT
    Company Id: #{company[:id]}
    Company Name: #{company[:name]}
    REPORT
end
