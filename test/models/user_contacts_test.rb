require "test_helper"

class UserContactsTest < ActiveSupport::TestCase
  setup do
    @user1 = users(:one) # Créer des utilisateurs de test
    @user2 = users(:two)
  end

  test "should add a contact successfully" do
    result = @user1.add_contact(@user2.username)
    
    assert result[:success]
    assert_includes @user1.contacts, @user2.id
  end

  test "should not add non-existent user as contact" do
    result = @user1.add_contact("non_existent_user")
    
    assert_not result[:success]
    assert_equal "Utilisateur introuvable", result[:error]
  end

  test "should not add self as contact" do
    result = @user1.add_contact(@user1.username)
    
    assert_not result[:success]
    assert_equal "Vous ne pouvez pas vous ajouter en tant que contact", result[:error]
  end

  test "should not add duplicate contact" do
    @user1.add_contact(@user2.username)
    result = @user1.add_contact(@user2.username)
    
    assert_not result[:success]
    assert_equal "Ce contact existe déjà", result[:error]
  end

  test "should remove contact successfully" do
    @user1.add_contact(@user2.username)
    result = @user1.remove_contact(@user2.id)
    
    assert result[:success]
    assert_not_includes @user1.contacts, @user2.id
  end

  test "should get contacts" do
    @user1.add_contact(@user2.username)
    contacts = @user1.get_contacts
    
    assert_equal 1, contacts.count
    assert_equal @user2.id, contacts.first.id
  end

  test "should check if user is contact" do
    @user1.add_contact(@user2.username)
    
    assert @user1.is_contact?(@user2.id)
    assert_not @user1.is_contact?(999)
  end

  test "contacts should persist after save" do
    @user1.add_contact(@user2.username)
    @user1.reload
    
    assert_includes @user1.contacts, @user2.id
  end

  test "should handle nil contacts gracefully" do
    @user1.contacts = nil
    contacts = @user1.get_contacts
    
    assert_equal [], contacts
  end

  test "should return empty array for non-contacts" do
    assert_equal [], @user1.get_contacts
  end
end
