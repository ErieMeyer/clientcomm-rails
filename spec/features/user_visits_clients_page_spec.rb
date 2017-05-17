require "rails_helper"
require "pry"

feature "logged-out user visits clients page" do
  scenario "and is redirected to the login form" do
    visit clients_path
    expect(page).to have_text "Log in"
    expect(page).to have_current_path(new_user_session_path)
  end
end

feature "logged-in user visits clients page" do
  scenario "successfully" do
    myuser = create :user
    visit root_path
    fill_in "Email", with: myuser.email
    fill_in "Password", with: myuser.password
    click_on "Sign in"
    expect(page).to have_text "My clients"
    expect(page).to have_current_path(root_path)
  end
end
