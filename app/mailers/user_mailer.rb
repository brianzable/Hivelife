class UserMailer < ApplicationMailer
  helper :users

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    mail(
      to: user.email,
      from: 'no-reply@hivelife.co',
      subject: 'Activate your Hivelife Account',
    )
  end

  def reset_password_email(user)
    @user = user
    mail(
      to: user.email,
      subject: 'Hivelife Password Reset',
      from: 'no-reply@hivelife.co'
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    # do nothing
  end
end
