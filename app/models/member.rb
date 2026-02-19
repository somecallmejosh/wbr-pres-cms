class Member < ApplicationRecord
  scope :alphabetical, -> { order(last_name: :asc, first_name: :asc) }
  scope :birthdays_this_month, -> {
    where("EXTRACT(MONTH FROM date_of_birth) = ?", Date.current.month)
      .order(Arel.sql("EXTRACT(DAY FROM date_of_birth) ASC"))
  }

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, length: { maximum: 255 }
  validates :phone, format: { with: /\A[\d\-() ]+\z/ }, allow_blank: true, length: { maximum: 20 }
  validates :state, length: { is: 2 }, allow_blank: true
  validates :zip_code, format: { with: /\A\d{5}(-\d{4})?\z/ }, allow_blank: true
  validate :date_of_birth_must_be_in_past

  def full_name
    "#{first_name} #{last_name}"
  end

  def birthday_display
    return nil unless date_of_birth

    "#{date_of_birth.strftime('%B')} #{date_of_birth.day.ordinalize}"
  end

  private

  def date_of_birth_must_be_in_past
    if date_of_birth.present? && date_of_birth >= Date.current
      errors.add(:date_of_birth, "must be in the past")
    end
  end
end
