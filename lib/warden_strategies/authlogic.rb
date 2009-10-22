Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :bcrypt
  manager.failure_app = SessionsController
end

# Setup Session Serialization
Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }
Warden::Manager.serialize_from_session{ |klass, id| klass.find(id) }

Warden::Strategies.add(:bcrypt) do
  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    return fail! unless user = User.find_by_login(params["username"])

    if user.crypted_password == "#{params["password"]}#{user.password_salt}"
      success!(user)
    else
      errors.add(:login, "Username or Password incorrect")
      fail!
    end
  end
end

Warden::Manager.after_authentication do |user, auth, opts|
  old_current = user.current_login_at
  old_current ||= user.current_login_at = DateTime.now
  user.last_login_at = old_current
  user.current_login_at = DateTime.now
  user.login_count = 0 if user.login_count.nil?
  user.login_count += 1
  user.save(false)
end
