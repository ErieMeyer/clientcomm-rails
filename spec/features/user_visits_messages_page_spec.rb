require "rails_helper"

feature "User clicks on client in list", :js do
  scenario "and sees the messages page" do
    # log in with a fake user
    myuser = create :user
    login_as(myuser, :scope => :user)
    # create a new client
    visit root_path
    click_on "New client"
    expect(page).to have_current_path(new_client_path)
    myclient = build :client
    myclient_fullname = myclient.full_name
    add_client(myclient)
    expect(page).to have_css '.data-table td', text: myclient_fullname
    expect(page).to have_current_path(clients_path)
    # click on the client
    find('td', text: myclient_fullname).click
    expect(page).to have_content myclient_fullname
    expect(page).to have_content PhoneNumberParser.format_for_display(myclient.phone_number)
    # get the id from the saved client record
    myclient_id = Client.find_by(phone_number: PhoneNumberParser.normalize(myclient.phone_number)).id
    expect(page).to have_current_path(client_messages_path(client_id: myclient_id))
  end
end
