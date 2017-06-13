class Client < ApplicationRecord
  belongs_to :user
  has_many :messages

  def full_name
    "#{first_name} #{last_name}"
  end

  def contacted_at
    # the date of the most recent message sent to or received from this client
    last_message = messages.order(:created_at).last
    if last_message
      return last_message.created_at
    end
    self.updated_at
  end

  def unread_message_count
    # the number of messages received that are unread
    messages.unread.count
  end

  def unread_message_sort
    # return a 0 or 1 to sort clients with unread messages on
    [self.unread_message_count, 1].min
  end

  # override default accessors
  def phone_number=(number_input)
    self[:phone_number] = PhoneNumberParser.normalize(number_input)
  end

end
