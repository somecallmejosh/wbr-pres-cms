require "test_helper"

class MemberTest < ActiveSupport::TestCase
  # Validations

  test "valid with required attributes" do
    member = Member.new(first_name: "John", last_name: "Doe")
    assert member.valid?
  end

  test "invalid without first_name" do
    member = Member.new(last_name: "Doe")
    assert_not member.valid?
    assert member.errors[:first_name].any?
  end

  test "invalid without last_name" do
    member = Member.new(first_name: "John")
    assert_not member.valid?
    assert member.errors[:last_name].any?
  end

  test "first_name cannot exceed 100 characters" do
    member = Member.new(first_name: "a" * 101, last_name: "Doe")
    assert_not member.valid?
    assert member.errors[:first_name].any?
  end

  test "last_name cannot exceed 100 characters" do
    member = Member.new(first_name: "John", last_name: "a" * 101)
    assert_not member.valid?
    assert member.errors[:last_name].any?
  end

  test "email allows blank" do
    member = Member.new(first_name: "John", last_name: "Doe", email: "")
    assert member.valid?
  end

  test "email validates format" do
    member = Member.new(first_name: "John", last_name: "Doe", email: "notanemail")
    assert_not member.valid?
    assert member.errors[:email].any?
  end

  test "email allows valid format" do
    member = Member.new(first_name: "John", last_name: "Doe", email: "john@example.com")
    assert member.valid?
  end

  test "email cannot exceed 255 characters" do
    member = Member.new(first_name: "John", last_name: "Doe", email: "#{"a" * 244}@example.com")
    assert_not member.valid?
    assert member.errors[:email].any?
  end

  test "phone allows blank" do
    member = Member.new(first_name: "John", last_name: "Doe", phone: "")
    assert member.valid?
  end

  test "phone validates format" do
    member = Member.new(first_name: "John", last_name: "Doe", phone: "abc-defg")
    assert_not member.valid?
    assert member.errors[:phone].any?
  end

  test "phone allows valid formats" do
    [ "555-1234", "(555) 123-4567", "5551234567" ].each do |phone|
      member = Member.new(first_name: "John", last_name: "Doe", phone: phone)
      assert member.valid?, "Expected #{phone} to be valid"
    end
  end

  test "phone cannot exceed 20 characters" do
    member = Member.new(first_name: "John", last_name: "Doe", phone: "1" * 21)
    assert_not member.valid?
    assert member.errors[:phone].any?
  end

  test "state must be exactly 2 characters if present" do
    member = Member.new(first_name: "John", last_name: "Doe", state: "LAX")
    assert_not member.valid?
    assert member.errors[:state].any?

    member.state = "LA"
    assert member.valid?
  end

  test "state allows blank" do
    member = Member.new(first_name: "John", last_name: "Doe", state: "")
    assert member.valid?
  end

  test "zip_code validates format" do
    member = Member.new(first_name: "John", last_name: "Doe", zip_code: "abc")
    assert_not member.valid?
    assert member.errors[:zip_code].any?
  end

  test "zip_code allows 5-digit format" do
    member = Member.new(first_name: "John", last_name: "Doe", zip_code: "70801")
    assert member.valid?
  end

  test "zip_code allows 9-digit format" do
    member = Member.new(first_name: "John", last_name: "Doe", zip_code: "70801-1234")
    assert member.valid?
  end

  test "zip_code allows blank" do
    member = Member.new(first_name: "John", last_name: "Doe", zip_code: "")
    assert member.valid?
  end

  test "date_of_birth must be in the past" do
    member = Member.new(first_name: "John", last_name: "Doe", date_of_birth: Date.current + 1)
    assert_not member.valid?
    assert member.errors[:date_of_birth].any?
  end

  test "date_of_birth allows past dates" do
    member = Member.new(first_name: "John", last_name: "Doe", date_of_birth: Date.new(1990, 1, 1))
    assert member.valid?
  end

  test "date_of_birth allows nil" do
    member = Member.new(first_name: "John", last_name: "Doe", date_of_birth: nil)
    assert member.valid?
  end

  # Scopes

  test "alphabetical scope orders by last_name then first_name" do
    members = Member.alphabetical
    assert_equal members(:alice), members.first
    assert_equal members(:bob), members.second
  end

  test "birthdays_this_month scope returns members with birthdays this month" do
    results = Member.birthdays_this_month
    assert_includes results, members(:birthday_this_month)
  end

  # Instance Methods

  test "full_name returns first and last name" do
    member = members(:alice)
    assert_equal "Alice Anderson", member.full_name
  end

  test "birthday_display returns formatted date" do
    member = Member.new(first_name: "John", last_name: "Doe", date_of_birth: Date.new(1990, 1, 15))
    assert_equal "January 15th", member.birthday_display
  end

  test "birthday_display returns nil when no date_of_birth" do
    member = members(:charlie)
    assert_nil member.birthday_display
  end
end
