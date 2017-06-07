module TwilioHelper
  def twilio_post_sms
    if Capybara.current_session.server
      conn = Faraday.new("#{myhost}")
      conn.post do |req|
        req.url '/incoming/sms'
        req.headers['X-Twilio-Signature'] = correct_signature
        req.body = twilio_params
      end
    else
      page.driver.header 'X-Twilio-Signature', correct_signature
      page.driver.post '/incoming/sms', twilio_params
    end
  end

  def twilio_message_text
    "This is a test message."
  end

  def twilio_params
    {"ToCountry"=>"US", "ToState"=>"CA", "SmsMessageSid"=>"49a5057738d311581dd5d005e97c2b5d0b", "NumMedia"=>"0", "ToCity"=>"", "FromZip"=>"94005", "SmsSid"=>"49a5057738d311581dd5d005e97c2b5d0b", "FromState"=>"CA", "SmsStatus"=>"received", "FromCity"=>"SAN FRANCISCO", "Body"=>twilio_message_text, "FromCountry"=>"US", "To"=>"+12435551212", "ToZip"=>"", "AddOns"=>"{\"status\":\"successful\",\"message\":null,\"code\":null,\"results\":{}}", "NumSegments"=>"1", "MessageSid"=>"49a5057738d311581dd5d005e97c2b5d0b", "AccountSid"=>"077541f41cce52ea6c4944fa6823a4a277", "From"=>"+12425551212", "ApiVersion"=>"2010-04-01", "controller"=>"twilio", "action"=>"incoming_sms"}
  end

  private

  def myhost
    if Capybara.current_session.server
      return "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}"
    end
    Capybara.current_host || Capybara.default_host
  end

  def correct_signature
    Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH_TOKEN'])
      .build_signature_for("#{myhost}/incoming/sms", twilio_params)
  end
end
