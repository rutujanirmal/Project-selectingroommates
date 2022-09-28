class ApplicationController < ActionController::API

  def get_current_user_details
    data = decode()
    if data
      details = {}
      details = data[0]
      current_user = User.find_by_emp_id(details["emp_id"])
      return current_user
    end
  end

  def encode(payload)
    JWT.encode(payload, secret_key_base)
  rescue StandardError
    nil
  end

  def secret_key_base
    Rails.application.secret_key_base if Rails.env.eql?('production')
    Rails.application.secrets.secret_key_base
  end

  def auth_header
    request.headers['Authorization']
  end

  def decode
    if auth_header
      token = auth_header.split(' ')[1]
      emp_id = JWT.decode token, secret_key_base, true, { algorithm: "HS256" }
      emp_id
    else
      render json: {message: I18n.t('session.invalid'), status_code: :unauthorized}
    end
  rescue StandardError
    nil
  end

end
