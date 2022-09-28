class UsersController < ApplicationController

  def new
    current_user = get_current_user_details()
    if (current_user.role == "admin")
      if user_parameters[:emp_id].present?
        if user_parameters[:full_name].present?
          if user_parameters[:gender].present?
            if user_parameters[:email].present?
              user = User.new(user_parameters)
              if(user.save!)
                render status: 200, json: {message: I18n.t('user.created_successfully')}
              else
                render status: 400
              end
            else
              render status: 400, json: {error: I18n.t('user.email_missing')}
            end
          else
            render status: 400, json: {error: I18n.t('user.gender_missing')}
          end
        else
          render status: 400, json: {error: I18n.t('user.full_name_missing')}
        end
      else
        render status: 400, json: {error: I18n.t('user.emp_id_missing')}
      end
    else
      render status: 400, json: {error: I18n.t('user.unauthorized')}
    end
  end

  def index
    current_user = get_current_user_details()
    if current_user
      if current_user.role == "employee"
        users = User.where(gender: current_user.gender, room_id: nil).where.not(emp_id: current_user.emp_id).pluck(:emp_id,:full_name)
      else
        users = User.where(gender: current_user.gender, room_id: nil).where.not(emp_id: current_user.emp_id).pluck(:emp_id,:full_name,:email)
      end
      if users.present?
        render status: 200, json: users.to_json
      else
        render status: 400, json: {error: I18n.t('user.everyone_booked')}
      end
    else
      render status: 404, json: {message: I18n.t('session.invalid'), status_code: :unauthorized}  
    end
  end

  def user_details
    email_id = params[:email]
    if(email_id.match(EMAIL_REGEX))
      user_details = User.where(email: email_id).pluck(:emp_id,:full_name,:room_id,:role).first
      if(user_details.present?)
        payload = {
          emp_id: user_details[0]
        }
        token = encode(payload)
        if(user_details[2])
          room = Room.find(user_details[2])
          roommates = User.where(emp_id: room.roommates).pluck(:full_name)
          render status: 400, json: {error: I18n.t('room.already_booked'), roommates: roommates}
        else
          render status: 200 , json: {emp_id: user_details[0],full_name: user_details[1],token: token,role: user_details[3]}
        end
      else
        render status: 400 , json: {error: I18n.t('email.not_found')}
      end
    else
      render status: 400 , json: {error: I18n.t('email.not_valid')}
    end
  end

  private

  def user_parameters
    params.require(:new_user_details).permit(:emp_id,:full_name,:gender,:email,:phone_no,:role)
  end

end
