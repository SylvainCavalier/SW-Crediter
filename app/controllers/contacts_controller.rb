class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contacts = current_user.contacts_list
    respond_to do |format|
      format.html
      format.json { render json: @contacts.map { |c| { id: c.id, type: c.class.name, name: contact_display_name(c) } } }
    end
  end

  def add
    name = params[:contact_username]&.strip
    result = current_user.add_contact(name)

    respond_to do |format|
      if result[:success]
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contacts-list",
            partial: "contacts/list", locals: { contacts: current_user.contacts_list })
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
    result = current_user.remove_contact(
      contactable_type: params[:contactable_type],
      contactable_id: params[:contactable_id]
    )

    respond_to do |format|
      if result[:success]
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contacts-list",
            partial: "contacts/list", locals: { contacts: current_user.contacts_list })
        end
        format.html { redirect_to new_holonew_path, notice: "Contact supprimé" }
        format.json { render json: result, status: :ok }
      else
        format.html { redirect_to new_holonew_path, alert: result[:error] }
        format.json { render json: result, status: :unprocessable_entity }
      end
    end
  end

  private

  def contact_display_name(contactable)
    contactable.is_a?(NpcCharacter) ? contactable.name : contactable.display_username
  end
end
