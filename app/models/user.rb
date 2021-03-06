class User < ApplicationRecord
  has_many :clients, dependent: :destroy
  has_many :messages

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :invitable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def analytics_tracker_data
    {
      clients_count: clients_count,
      has_unread_messages: unread_messages_count > 0,
      unread_messages_count: unread_messages_count
    }
  end

  def unread_messages_count
    # the number of messages received that are unread
    messages.unread.count
  end

  def clients_count
    # the number of associated clients
    clients.count
  end


end
