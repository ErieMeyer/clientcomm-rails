require 'rails_helper'

describe 'Twilio controller', type: :request do
  let(:user) { create :user }
  let(:client) { create(:client, user: user) }

  before do
    sign_in user
  end

  context 'POST#incoming_sms' do
    let(:message_text) { 'Hello, this is a new message from a client!' }
    let(:message_params) {
      twilio_new_message_params(
          from_number: client.phone_number,
          msg_txt: message_text
      )
    }

    before do
      twilio_post_sms message_params
    end

    it 'saves an incoming sms message' do
      msg = user.messages.last
      expect(msg).not_to eq nil
      expect(msg.body).to eq message_text
    end

    it 'tracks an incoming sms message' do
      expect_analytics_events(
          {
              'message_receive' => {
                  'client_id' => client.id,
                  'message_length' => message_text.length,
                  'attachments_count' => 0
              }
          }
      )
    end

    context 'sms message contains an attachment' do
      let(:message_params) {
        twilio_new_message_params(
            from_number: client.phone_number,
            msg_txt: message_text,
            media_count: 1
        )
      }

      it 'tracks an analytics event for the attachment' do
        expect_analytics_events(
            {
                'message_receive' => {
                    'client_id' => client.id,
                    'message_length' => message_text.length,
                    'attachments_count' => 1
                }
            }
        )
      end
    end
  end

  context 'POST#incoming_sms_status' do
    it 'saves a successful sms message status update' do
      msgone = create :message, user: user, client: client, inbound: true, twilio_status: 'queued'
      # validate the status
      expect(client.messages.last.twilio_status).to eq 'queued'

      # post a status update
      status_params = twilio_status_update_params from_number: client.phone_number, sms_sid: msgone.twilio_sid, sms_status: 'received'
      twilio_post_sms_status status_params

      # validate the updated status
      expect(client.messages.last.twilio_status).to eq 'received'

      # no failed analytics event
      expect_analytics_events_not_happened('message_send_failed')
    end

    it 'saves an unsuccessful sms message status update' do
      msgone = create :message, user: user, client: client, inbound: true, twilio_status: 'queued'
      # validate the status
      expect(client.messages.last.twilio_status).to eq 'queued'

      # post a status update
      status_params = twilio_status_update_params from_number: client.phone_number, sms_sid: msgone.twilio_sid, sms_status: 'failed'
      twilio_post_sms_status status_params

      # validate the updated status
      expect(client.messages.last.twilio_status).to eq 'failed'

      # failed analytics event
      expect_analytics_events_happened('message_send_failed')
    end
  end
end

