require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @member = members(:alice)
    sign_in_as(@user)
  end

  # Auth tests

  test "index requires authentication" do
    sign_out
    get members_url
    assert_redirected_to new_session_path
  end

  test "show requires authentication" do
    sign_out
    get member_url(@member)
    assert_redirected_to new_session_path
  end

  test "new requires authentication" do
    sign_out
    get new_member_url
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    sign_out
    post members_url, params: { member: { first_name: "Test", last_name: "User" } }
    assert_redirected_to new_session_path
  end

  test "edit requires authentication" do
    sign_out
    get edit_member_url(@member)
    assert_redirected_to new_session_path
  end

  test "update requires authentication" do
    sign_out
    patch member_url(@member), params: { member: { first_name: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "destroy requires authentication" do
    sign_out
    delete member_url(@member)
    assert_redirected_to new_session_path
  end

  test "destroy_all requires authentication" do
    sign_out
    assert_no_difference("Member.count") do
      delete destroy_all_members_url
    end
    assert_redirected_to new_session_path
  end

  test "bulk_destroy requires authentication" do
    sign_out
    assert_no_difference("Member.count") do
      delete bulk_destroy_members_url, params: { member_ids: [ @member.id ] }
    end
    assert_redirected_to new_session_path
  end

  # CRUD tests

  test "should get index" do
    get members_url
    assert_response :success
  end

  test "should get new" do
    get new_member_url
    assert_response :success
  end

  test "should create member" do
    assert_difference("Member.count") do
      post members_url, params: { member: { first_name: "Jane", last_name: "Smith", email: "jane@example.com" } }
    end

    assert_redirected_to member_url(Member.last)
  end

  test "should not create member with invalid data" do
    assert_no_difference("Member.count") do
      post members_url, params: { member: { first_name: "", last_name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should show member" do
    get member_url(@member)
    assert_response :success
  end

  test "should get edit" do
    get edit_member_url(@member)
    assert_response :success
  end

  test "should update member" do
    patch member_url(@member), params: { member: { first_name: "Updated" } }
    assert_redirected_to member_url(@member)
    @member.reload
    assert_equal "Updated", @member.first_name
  end

  test "should not update member with invalid data" do
    patch member_url(@member), params: { member: { first_name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy member" do
    assert_difference("Member.count", -1) do
      delete member_url(@member)
    end

    assert_redirected_to members_url
  end

  test "should destroy all members" do
    assert_operator Member.count, :>, 0

    delete destroy_all_members_url

    assert_equal 0, Member.count
    assert_redirected_to members_url
  end

  test "should bulk destroy selected members" do
    ids = [ members(:alice).id, members(:bob).id ]

    assert_difference("Member.count", -2) do
      delete bulk_destroy_members_url, params: { member_ids: ids }
    end

    assert_redirected_to members_url
    assert_not Member.exists?(members(:alice).id)
    assert_not Member.exists?(members(:bob).id)
    assert Member.exists?(members(:charlie).id)
  end

  test "bulk destroy with no selection deletes nothing" do
    assert_no_difference("Member.count") do
      delete bulk_destroy_members_url, params: { member_ids: [ "" ] }
    end

    assert_redirected_to members_url
  end

  test "bulk destroy with missing param deletes nothing" do
    assert_no_difference("Member.count") do
      delete bulk_destroy_members_url
    end

    assert_redirected_to members_url
  end
end
