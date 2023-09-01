require "yaml"
require "json"

require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @users = YAML.load_file("users.yaml")
end

get "/" do
  redirect "/users"
end

get "/users" do
  erb :users
end

post "/new-user" do
  data = CGI.unescape(request.body.read)

  new_user = data.split('&').map do |pair|
    key_value = pair.split('=')
    {key_value[0].to_sym => key_value[1]}
  end

  @user_name = new_user[0][:name]
  @email = new_user[1][:email]
  @interests = new_user[2][:interests].split(', ')

  update_users(@user_name, @email, @interests)

  redirect "/#{@user_name}"
end

not_found do
  erb :not_found
end

get "/:user_name" do
  @user_name = params[:user_name].to_sym
  @email = @users[@user_name][:email]
  @interests = @users[@user_name][:interests]

  erb :user, layout: :sub_list_layout
end

def update_users(name, email, interests)
  users_current = File.read("users.yaml")
  users_updated = YAML.load users_current
  
  users_updated[name.to_sym] = {
    email: email,
    interests: interests
  }

  File.write("users.yaml", YAML.dump(users_updated))
end

helpers do 
  def count_interests
    count = 0
    @users.each do |name, info|
      count += info[:interests].size
    end
    count
  end
end