def authenticated_header()
  email, password = "admin@mail.com", "123"
  FactoryGirl.create(:user, email: email, password: password)
  response = AuthenticateUser.call(email, password)
  return { :Authorization => response.result }
end
