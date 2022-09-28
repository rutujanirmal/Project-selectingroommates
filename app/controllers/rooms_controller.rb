class RoomsController < ApplicationController
  def new
    current_user = get_current_user_details()
    if current_user.instance_of? User
      roommate2 = parameters[:roommate2]
      roommate3 = parameters[:roommate3]
      roommates = [current_user.emp_id,roommate2,roommate3]
      if(current_user.room_id)
        room = Room.find(current_user.room_id)
        roommates = User.where(emp_id: room.roommates).pluck(:full_name)
        render status: 400, json: {error: I18n.t('room.already_booked'), roommates: roommates}
      elsif no_one_already_allocated?roommates and same_gender?roommates
        room = Room.new
        room.booked_by = current_user.full_name
        room.roommates = roommates
        if (room.save!)
          roommates = User.where(emp_id: room.roommates).update_all(room_id: room.id)
          render status: 200, json: {message: I18n.t('room.booking_success')}
        else
          render status: 422
        end
      end
    else
      render status: 404, json: {error: I18n.t('session.invalid'), status_code: :unauthorized} 
    end
  end

  private

  def parameters
    params.require(:room_mate_details).permit(:roommate2,:roommate3)
  end

  def no_one_already_allocated?(roommates)
    already_booked_emp = User.where(emp_id: roommates).where.not(room_id: nil).pluck(:full_name)
    unless already_booked_emp.present?
      true
    else
      render json: {error: I18n.t('room.already_booked'),roommates: already_booked_emp}
      false
    end
  end

  def same_gender?(roommates)
    gender = User.where(emp_id: roommates).pluck(:gender)
    gender.uniq.length == 1 ? true : false
  end
end
