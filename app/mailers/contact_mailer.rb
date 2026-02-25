class ContactMailer < ApplicationMailer
  CONTACT_EMAIL = ENV['CONTACT_EMAIL']

  def inquiry(name:, email:, message:)
    @name = name
    @email = email
    @message = message

    mail(
      from: "WBR Presbyterian <office@wbrpres.org>",
      to: CONTACT_EMAIL,
      reply_to: email,
      subject: "Contact form message from #{name}"
    )
  end
end
