class Notifier < ActionMailer::Base
  default to: "bugs@isthat.it"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.feedback_form.subject
  #
  def send_email(data)
    @type = data[:type]
    @message = data[:message]
    @name = data[:name]
    @from = data[:email]
    
    mail(
      :from => @from, 
      :reply_to => @from,
      :subject => "#{@type} - contact form on project.shearn89.com"
    )
  end
end
