# Admin user
User.find_or_create_by!(email_address: "josh@thebrileys.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

# Members (24 total, at least one birthday per month)
members_data = [
  { first_name: "Margaret", last_name: "Thompson", email: "margaret.thompson@example.com", phone: "(225) 555-0101", address_line1: "101 Magnolia Dr", city: "Baton Rouge", state: "LA", zip_code: "70801", date_of_birth: "1958-01-08" },
  { first_name: "Robert", last_name: "Campbell", email: "robert.campbell@example.com", phone: "(225) 555-0102", address_line1: "204 Oak Valley Rd", city: "Baton Rouge", state: "LA", zip_code: "70802", date_of_birth: "1962-02-14" },
  { first_name: "Patricia", last_name: "Williams", email: "patricia.williams@example.com", phone: "(225) 555-0103", address_line1: "317 Cypress Ln", city: "Baton Rouge", state: "LA", zip_code: "70803", date_of_birth: "1975-03-22" },
  { first_name: "James", last_name: "Anderson", email: "james.anderson@example.com", phone: "(225) 555-0104", address_line1: "430 Pecan St", city: "Baton Rouge", state: "LA", zip_code: "70801", date_of_birth: "1980-04-05" },
  { first_name: "Linda", last_name: "Mitchell", email: "linda.mitchell@example.com", phone: "(225) 555-0105", address_line1: "558 Birch Ave", city: "Baton Rouge", state: "LA", zip_code: "70806", date_of_birth: "1968-05-17" },
  { first_name: "William", last_name: "Taylor", email: "william.taylor@example.com", phone: "(225) 555-0106", address_line1: "612 Elm Ct", city: "Baton Rouge", state: "LA", zip_code: "70808", date_of_birth: "1955-06-30" },
  { first_name: "Barbara", last_name: "Harris", email: "barbara.harris@example.com", phone: "(225) 555-0107", address_line1: "725 Willow Way", city: "Baton Rouge", state: "LA", zip_code: "70809", date_of_birth: "1972-07-11" },
  { first_name: "David", last_name: "Jackson", email: "david.jackson@example.com", phone: "(225) 555-0108", address_line1: "839 Cedar Blvd", city: "Baton Rouge", state: "LA", zip_code: "70810", date_of_birth: "1984-08-25" },
  { first_name: "Susan", last_name: "White", email: "susan.white@example.com", phone: "(225) 555-0109", address_line1: "941 Poplar Dr", city: "Baton Rouge", state: "LA", zip_code: "70811", date_of_birth: "1966-09-03" },
  { first_name: "Richard", last_name: "Martin", email: "richard.martin@example.com", phone: "(225) 555-0110", address_line1: "1053 Hickory Ln", city: "Baton Rouge", state: "LA", zip_code: "70812", date_of_birth: "1978-10-19" },
  { first_name: "Dorothy", last_name: "Garcia", email: "dorothy.garcia@example.com", phone: "(225) 555-0111", address_line1: "1167 Maple St", city: "Baton Rouge", state: "LA", zip_code: "70801", date_of_birth: "1960-11-07" },
  { first_name: "Charles", last_name: "Robinson", email: "charles.robinson@example.com", phone: "(225) 555-0112", address_line1: "1280 Pine Ave", city: "Baton Rouge", state: "LA", zip_code: "70802", date_of_birth: "1970-12-24" },
  { first_name: "Elizabeth", last_name: "Clark", email: "elizabeth.clark@example.com", phone: "(225) 555-0113", address_line1: "1392 Dogwood Ct", city: "Baton Rouge", state: "LA", zip_code: "70803", date_of_birth: "1988-01-29" },
  { first_name: "Thomas", last_name: "Lewis", email: "thomas.lewis@example.com", phone: "(225) 555-0114", address_line1: "1405 Sycamore Rd", city: "Baton Rouge", state: "LA", zip_code: "70806", date_of_birth: "1952-02-20" },
  { first_name: "Mary", last_name: "Walker", email: "mary.walker@example.com", phone: "(225) 555-0115", address_line1: "1518 Azalea Blvd", city: "Baton Rouge", state: "LA", zip_code: "70808", date_of_birth: "1983-05-09" },
  { first_name: "Joseph", last_name: "Hall", phone: "(225) 555-0116", address_line1: "1624 Jasmine Dr", city: "Baton Rouge", state: "LA", zip_code: "70809", date_of_birth: "1976-07-04" },
  { first_name: "Helen", last_name: "Allen", email: "helen.allen@example.com", phone: "(225) 555-0117", address_line1: "1730 Iris Ln", city: "Baton Rouge", state: "LA", zip_code: "70810", date_of_birth: "1964-09-15" },
  { first_name: "Daniel", last_name: "Young", email: "daniel.young@example.com", phone: "(225) 555-0118", address_line1: "1846 Laurel St", city: "Baton Rouge", state: "LA", zip_code: "70811", date_of_birth: "1991-03-12" },
  { first_name: "Ruth", last_name: "King", email: "ruth.king@example.com", phone: "(225) 555-0119", address_line1: "1952 Camellia Ave", address_line2: "Apt 3", city: "Baton Rouge", state: "LA", zip_code: "70812", date_of_birth: "1957-06-18" },
  { first_name: "Paul", last_name: "Wright", email: "paul.wright@example.com", phone: "(225) 555-0120", address_line1: "2065 Gardenia Ct", city: "Baton Rouge", state: "LA", zip_code: "70801", date_of_birth: "1986-08-02" },
  { first_name: "Karen", last_name: "Scott", email: "karen.scott@example.com", phone: "(225) 555-0121", address_line1: "2178 Verbena Rd", city: "Baton Rouge", state: "LA", zip_code: "70802", date_of_birth: "1973-10-31" },
  { first_name: "Mark", last_name: "Green", email: "mark.green@example.com", phone: "(225) 555-0122", address_line1: "2284 Tulip Blvd", city: "Baton Rouge", state: "LA", zip_code: "70803", date_of_birth: "1969-04-27" },
  { first_name: "Betty", last_name: "Adams", email: "betty.adams@example.com", address_line1: "2390 Primrose Dr", city: "Baton Rouge", state: "LA", zip_code: "70806", date_of_birth: "1981-11-13" },
  { first_name: "George", last_name: "Nelson", email: "george.nelson@example.com", phone: "(225) 555-0124", address_line1: "2496 Bluebell Ln", address_line2: "Suite B", city: "Baton Rouge", state: "LA", zip_code: "70808", date_of_birth: "1995-12-06" }
]

members_data.each do |attrs|
  Member.find_or_create_by!(first_name: attrs[:first_name], last_name: attrs[:last_name]) do |member|
    member.assign_attributes(attrs)
  end
end

puts "Seeded #{Member.count} members"
