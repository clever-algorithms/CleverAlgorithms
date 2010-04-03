require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create message" do
    assert_difference('Message.count') do
      post :create, :message => { }
    end

    assert_redirected_to message_path(assigns(:message))
  end

  test "should show message" do
    get :show, :id => messages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => messages(:one).to_param
    assert_response :success
  end

  test "should update message" do
    put :update, :id => messages(:one).to_param, :message => { }
    assert_redirected_to message_path(assigns(:message))
  end

  test "should destroy message" do
    assert_difference('Message.count', -1) do
      delete :destroy, :id => messages(:one).to_param
    end

    assert_redirected_to messages_path
  end
end
