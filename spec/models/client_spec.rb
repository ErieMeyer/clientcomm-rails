require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'relationships' do
    let!(:user) { create :user }
    let!(:client) { create :client, :user => user }
    let!(:message) { create :message, :user => user, :client => client}

    describe 'relationship to user' do
      it 'belongs to a user' do
        expect(client.user).to eq(user)
      end
    end

    describe 'relationship to message' do
      it 'has a message' do
        expect(message.client).to eq(client)
      end
    end
  end

  describe 'accessors' do
    let!(:user) { create :user }
    subject { create :client, :user => user }

    describe '#full_name' do
      it 'formats full name' do
        expect(subject.full_name).to eq(subject.first_name + " " + subject.last_name)
      end
    end

    describe '#phone_number=' do
      it 'normalizes phone number' do
        subject.phone_number = '2435551212'
        expect(subject.phone_number).to eql '+12435551212'
      end
    end
  end

  describe 'validations' do
    it {
      should validate_presence_of(:last_name)
      should validate_presence_of(:birth_date)
    }

    it 'validates presence of phone_number' do
      client = Client.new(last_name: 'Last', birth_date: DateTime.now)
      expect(client.valid?).to be_falsey
      expect([:phone_number]).to eql client.errors.keys
    end
  end

end
