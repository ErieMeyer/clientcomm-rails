require "rails_helper"

feature 'sending messages' do
  let(:message_body) {'You have an appointment tomorrow at 10am'}
  let(:client_1) { build :client }
  let(:client_2) { build :client }

  scenario 'user sends message to client', :js do
    step 'when i log in' do
      myuser = create :user
      login_as(myuser, scope: :user)
    end

    step 'when i create two clients' do
      travel_to 7.days.ago do
        add_client(client_1)
        add_client(client_2)
      end
    end

    step 'when i go to messages page' do
      myclient_id = Client.find_by(phone_number: PhoneNumberParser.normalize(client_1.phone_number)).id
      visit client_messages_path(client_id: myclient_id)
    end

    step 'when i send a message' do
      fill_in 'Send a text message', with: message_body
      click_on 'send_message'
    end

    step 'then i see the message displayed' do
      expect(page).to have_css '.message--outbound div', text: message_body

      # get the message object and find the dom_id
      myclient_id = Client.find_by(phone_number: PhoneNumberParser.normalize(client_1.phone_number)).id
      mymessage = Message.find_by(client_id: myclient_id, body: message_body)
      expect(page).to have_css '.message--outbound', id: dom_id(mymessage)
    end

    step 'when i visit the clients page' do
      visit clients_path
    end

    step 'then i see clients sorted by last contact time' do
      savedfirstclient = Client.find_by(phone_number: PhoneNumberParser.normalize(client_1.phone_number))
      savedsecondclient = Client.find_by(phone_number: PhoneNumberParser.normalize(client_2.phone_number))
      expect(page).to have_css "tr##{dom_id(savedfirstclient)} td", text: 'less than a minute'
      expect(page).to have_css "tr##{dom_id(savedsecondclient)} td", text: '7 days'
    end
  end
end
