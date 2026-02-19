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

# Events (at least 3 per week over the next 3 months)
events_data = [
  # Week 1: Feb 17–23
  { title: "Adult Bible Study", description: "Weekly study of the Gospel of John, led by Pastor Reynolds.", event_date: "2026-02-18", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Session Meeting", description: "Monthly meeting of the Session to discuss church business.", event_date: "2026-02-19", start_time: "19:00", end_time: "20:30", location: "Conference Room", category: "meetings" },
  { title: "Youth Game Night", description: "Fun and fellowship for middle and high school students.", event_date: "2026-02-20", start_time: "18:00", end_time: "20:00", location: "Youth Room", category: "fellowship" },

  # Week 2: Feb 24–Mar 1
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-02-25", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Community Food Pantry", description: "Distributing food to families in need. Volunteers welcome.", event_date: "2026-02-26", start_time: "09:00", end_time: "12:00", location: "Church Parking Lot", category: "community_service" },
  { title: "Women's Fellowship Luncheon", description: "Monthly gathering with a potluck meal and devotional.", event_date: "2026-02-27", start_time: "11:30", end_time: "13:00", location: "Fellowship Hall", category: "fellowship" },

  # Week 3: Mar 2–8
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-03-04", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Deacons Meeting", description: "Monthly deacons meeting to coordinate congregational care.", event_date: "2026-03-05", start_time: "19:00", end_time: "20:00", location: "Conference Room", category: "meetings" },
  { title: "Family Movie Night", description: "Screening a family-friendly film with popcorn and refreshments.", event_date: "2026-03-06", start_time: "18:30", end_time: "20:30", location: "Fellowship Hall", category: "fellowship" },

  # Week 4: Mar 9–15
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-03-11", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Finance Committee Meeting", description: "Quarterly review of church finances.", event_date: "2026-03-12", start_time: "18:00", end_time: "19:00", location: "Conference Room", category: "meetings" },
  { title: "Habitat Build Day", description: "Helping build a home with Habitat for Humanity. All skill levels welcome.", event_date: "2026-03-14", start_time: "08:00", end_time: "15:00", location: "Habitat Build Site", category: "community_service" },
  { title: "Men's Breakfast", description: "Fellowship over a hot breakfast with a short devotional.", event_date: "2026-03-14", start_time: "07:30", end_time: "09:00", location: "Fellowship Hall", category: "fellowship" },

  # Week 5: Mar 16–22
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-03-18", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Session Meeting", description: "Monthly meeting of the Session.", event_date: "2026-03-19", start_time: "19:00", end_time: "20:30", location: "Conference Room", category: "meetings" },
  { title: "Spring Fellowship Dinner", description: "A church-wide dinner to celebrate the coming of spring.", event_date: "2026-03-21", start_time: "17:30", end_time: "19:30", location: "Fellowship Hall", category: "fellowship" },

  # Week 6: Mar 23–29
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-03-25", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Neighborhood Cleanup Day", description: "Joining neighbors to clean up streets and parks around the church.", event_date: "2026-03-28", start_time: "09:00", end_time: "12:00", location: "Church Grounds", category: "community_service" },
  { title: "Youth Lock-In", description: "Overnight event for youth with games, worship, and small groups.", event_date: "2026-03-27", start_time: "19:00", location: "Youth Room", category: "fellowship" },

  # Week 7: Mar 30–Apr 5
  { title: "Adult Bible Study", description: "Continuing our study of the Gospel of John.", event_date: "2026-04-01", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Deacons Meeting", description: "Monthly deacons meeting.", event_date: "2026-04-02", start_time: "19:00", end_time: "20:00", location: "Conference Room", category: "meetings" },
  { title: "Easter Egg Hunt", description: "Annual egg hunt for children ages 2-10 on the church lawn.", event_date: "2026-04-04", start_time: "10:00", end_time: "11:30", location: "Church Lawn", category: "fellowship" },

  # Week 8: Apr 6–12
  { title: "Adult Bible Study", description: "Holy Week study focusing on the Passion narrative.", event_date: "2026-04-08", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Women's Fellowship Luncheon", description: "Monthly gathering with a potluck meal and devotional.", event_date: "2026-04-09", start_time: "11:30", end_time: "13:00", location: "Fellowship Hall", category: "fellowship" },
  { title: "Clothing Drive Collection", description: "Collecting gently used clothing for local shelters.", event_date: "2026-04-11", start_time: "09:00", end_time: "14:00", location: "Church Parking Lot", category: "community_service" },

  # Week 9: Apr 13–19
  { title: "Adult Bible Study", description: "Beginning a new series on the book of Psalms.", event_date: "2026-04-15", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Session Meeting", description: "Monthly meeting of the Session.", event_date: "2026-04-16", start_time: "19:00", end_time: "20:30", location: "Conference Room", category: "meetings" },
  { title: "Church Picnic", description: "Annual spring picnic at the park. Bring a side dish to share.", event_date: "2026-04-18", start_time: "11:00", end_time: "14:00", location: "Highland Road Park", category: "fellowship" },

  # Week 10: Apr 20–26
  { title: "Adult Bible Study", description: "Continuing our study of the Psalms.", event_date: "2026-04-22", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Community Food Pantry", description: "Monthly food distribution. Volunteers needed starting at 8 AM.", event_date: "2026-04-23", start_time: "09:00", end_time: "12:00", location: "Church Parking Lot", category: "community_service" },
  { title: "Men's Breakfast", description: "Fellowship over a hot breakfast with a short devotional.", event_date: "2026-04-25", start_time: "07:30", end_time: "09:00", location: "Fellowship Hall", category: "fellowship" },

  # Week 11: Apr 27–May 3
  { title: "Adult Bible Study", description: "Continuing our study of the Psalms.", event_date: "2026-04-29", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Property Committee Meeting", description: "Reviewing building maintenance needs and summer projects.", event_date: "2026-04-30", start_time: "18:00", end_time: "19:00", location: "Conference Room", category: "meetings" },
  { title: "Game Night", description: "Board games and card games for all ages.", event_date: "2026-05-01", start_time: "18:30", end_time: "20:30", location: "Fellowship Hall", category: "fellowship" },

  # Week 12: May 4–10
  { title: "Adult Bible Study", description: "Continuing our study of the Psalms.", event_date: "2026-05-06", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Deacons Meeting", description: "Monthly deacons meeting.", event_date: "2026-05-07", start_time: "19:00", end_time: "20:00", location: "Conference Room", category: "meetings" },
  { title: "Mother's Day Tea", description: "Honoring the mothers and women of the congregation with tea and desserts.", event_date: "2026-05-09", start_time: "14:00", end_time: "15:30", location: "Fellowship Hall", category: "fellowship" },

  # Week 13: May 11–17
  { title: "Adult Bible Study", description: "Continuing our study of the Psalms.", event_date: "2026-05-13", start_time: "18:30", end_time: "19:30", location: "Fellowship Hall", category: "education" },
  { title: "Vacation Bible School Planning", description: "Planning committee meeting for this summer's VBS.", event_date: "2026-05-14", start_time: "19:00", end_time: "20:00", location: "Conference Room", category: "meetings" },
  { title: "Habitat Build Day", description: "Continuing our partnership with Habitat for Humanity.", event_date: "2026-05-16", start_time: "08:00", end_time: "15:00", location: "Habitat Build Site", category: "community_service" },
]

events_data.each do |attrs|
  Event.find_or_create_by!(title: attrs[:title], event_date: attrs[:event_date]) do |event|
    event.assign_attributes(attrs)
  end
end

puts "Seeded #{Event.count} events"
