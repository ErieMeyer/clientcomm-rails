class FrontImport
  def initialize(front_token:)
    @front_token = front_token
    @front_client = Frontapp::Client.new(auth_token: @front_token)
  end

  def create_contact_from_id(user:, contact_id:)
    response = @front_client.get_contact(contact_id)
    phone_number = response['handles'][0]['handle']

    if response['name']
      split_name = response['name'].split(' ')
      if split_name.length < 2
        Client.create!(
            phone_number: phone_number,
            last_name: response['name'],
            user: user
        )
      else
        Client.create!(
            phone_number: phone_number,
            first_name: split_name[0],
            last_name: split_name[1],
            user: user
        )
      end
    else
      create_contact_from_phone_number(user: user, phone_number: phone_number)
    end
  end

  def create_contact_from_phone_number(user:, phone_number:)
    Client.create!(
        phone_number: phone_number,
        last_name: phone_number,
        user: user
    )
  end

  def conversations(user:, inbox_id:)
    response = @front_client.get_inbox_conversations(inbox_id)

    response.map do |result|
      contact = result['recipient']['_links']['related']['contact']

      if contact.nil?
        create_contact_from_phone_number(user: user, phone_number: result['recipient']['handle'])
      else

        ap result
        create_contact_from_id(user: user, contact_id: contact.sub('https://api2.frontapp.com/contacts/', ''))
      end

      result['id']
    end
  end

  def inboxes
    @inboxes ||= get_inboxes
  end

  def import(email:)
    teammates = @front_client.teammates

    user = teammates.find do |teammate|
      teammate['email'] == email
    end

    user = User.create!(full_name: "#{user['first_name']} #{user['last_name']}", email: email, password: SecureRandom.uuid)

    # get the inbox for the provided user name
    inbox_id = inboxes[user.full_name]

    # get all conversations
    conversation_ids = conversations(user: user, inbox_id: inbox_id)

    # import all messages
  end


  private

  def inbox_url(inbox_id)
    "https://api2.frontapp.com/inboxes/#{inbox_id}/conversations?limit=100"
  end

  def headers
    {
        'Authorization': "Bearer #{@front_token}",
        'Accept': 'application/json'
    }
  end

  def get_inboxes
    response = @front_client.inboxes
    raise StandardError if response.empty?

    inboxes = {}

    response.each do |result|
      inboxes[result['name']] = result['id']
    end

    inboxes
  end
end
