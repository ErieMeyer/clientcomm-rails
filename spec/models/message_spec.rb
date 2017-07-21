require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'relationships' do
    it do
      should belong_to :client
      should belong_to :user
      should have_many :attachments
    end
  end

  describe '#create_from_twilio' do
    context 'client does not exist' do
      let!(:unclaimed_user) { create(:user, email: ENV['UNCLAIMED_EMAIL']) }

      it 'creates a new client with missing information' do
        unknown_number = '+19999999999'
        params = twilio_new_message_params from_number: unknown_number

        message = Message.create_from_twilio!(params)

        expect(message.user).to eq unclaimed_user
        expect(message.number_to).to eq ENV['TWILIO_PHONE_NUMBER']
        expect(message.number_from).to eq unknown_number
        expect(message.inbound).to be_truthy

        client = message.client
        expect(client.first_name).to be_nil
        expect(client.last_name).to eq unknown_number
        expect(client.phone_number).to eq unknown_number
        expect(client.user).to eq unclaimed_user
      end
    end

    context 'client exists' do
      let(:client) { create :client }

      it 'creates a message if proper params are sent' do
        params = twilio_new_message_params from_number: client.phone_number
        msg = Message.create_from_twilio!(params)
        expect(client.messages.last).to eq msg
      end

      it 'creates a message with attachments' do
        params = twilio_new_message_params(
            from_number: client.phone_number, media_count: 2
        )
        msg = Message.create_from_twilio!(params)
        expect(msg).not_to eq nil

        attachments = msg.attachments.all
        expect(attachments.length).to eq 2

        urls = attachments.map(&:url)
        expect(urls).to match_array(params.fetch_values('MediaUrl0', 'MediaUrl1'))

        types = attachments.map(&:content_type)
        expect(types).to match_array(params.fetch_values('MediaContentType0', 'MediaContentType1'))
      end
    end
  end

end
