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
  report = app(companies, users)
  puts report
end

def app(companies, users)
  database = build_database(companies, users)
  update_user_balances!(database)
  report = ""
  database.values.map do |company|
    report += build_company_report(company)
  end
  report
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

def update_user_balances!(database)
  database.values.map do |company|
    unless company[:top_ups_given]
      company[:top_ups_given] = 0
    end
    top_up_amount = company[:top_up]
    company[:users].filter { |user| user[:active_status] }.map do |user|
      user[:tokens] += top_up_amount
      company[:top_ups_given] += top_up_amount
    end
  end
  database
end

def build_company_report(company)
  report = <<~REPORT
    Company Id: #{company[:id]}
    Company Name: #{company[:name]}
  REPORT

  emailed_users = company[:users].filter {
    |user| user[:email_status] && user[:active_status]
  }
  report += <<~REPORT
    Users Emailed:
    REPORT
  emailed_users.map do |user|
    report += build_user_report(user)
  end

  not_emailed_users = company[:users].filter {
    |user| !user[:email_status] || !user[:active_status]
  }
  report += <<~REPORT
    Users Not Emailed:
    REPORT
  not_emailed_users.map do |user|
    report += build_user_report(user)
  end

  report
end

def build_user_report(user)
  report = <<~REPORT
    #{user[:last_name]}, #{user[:first_name]}, #{user[:email]}
      Previous Token Balance, #{user[:tokens]}
      New Token Balance #{user[:previous_tokens]}
  REPORT
end

def symbolize_keys(a_hash)
  a_hash.transform_keys(&:to_sym)
end
