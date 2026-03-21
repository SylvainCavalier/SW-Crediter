class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contacts = current_user.get_contacts
    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  def add
    contact_username = params[:contact_username]&.strip
    result = current_user.add_contact(contact_username)

    respond_to do |format|
      if result[:success]
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contacts-list", 
            partial: "contacts/list", locals: { contacts: current_user.get_contacts })
        end
        format.html { redirect_to new_holonew_path, notice: "Contact ajouté avec succès" }
        format.json { render json: result, status: :created }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("contact-error", 
            partial: "contacts/error", locals: { error: result[:error] })
        end
        format.html { redirect_to new_holonew_path, alert: result[:error] }
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  def remove
    contact_id = params[:contact_id]
    result = current_user.remove_contact(contact_id)

    respond_to do |format|
      if result[:success]
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contacts-list", 
            partial: "contacts/list", locals: { contacts: current_user.get_contacts })
        end
        format.html { redirect_to new_holonew_path, notice: "Contact supprimé" }
        format.json { render json: result, status: :ok }
      else
        format.html { redirect_to new_holonew_path, alert: result[:error] }
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end
end
