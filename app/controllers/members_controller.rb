class MembersController < ApplicationController
  before_action :set_member, only: %i[show edit update destroy]

  def index
    @members = Member.alphabetical
  end

  def show
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)

    if @member.save
      redirect_to @member, notice: "Member was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @member.update(member_params)
      redirect_to @member, notice: "Member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy!
    redirect_to members_path, notice: "Member was successfully deleted.", status: :see_other
  end

  private

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    params.expect(member: [:first_name, :last_name, :email, :phone, :address_line1, :address_line2, :city, :state, :zip_code, :date_of_birth])
  end
end
