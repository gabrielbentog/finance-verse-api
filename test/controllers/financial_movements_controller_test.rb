require "test_helper"

class FinancialMovementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @financial_movement = financial_movements(:one)
  end

  test "should get index" do
    get financial_movements_url
    assert_response :success
  end

  test "should get new" do
    get new_financial_movement_url
    assert_response :success
  end

  test "should create financial_movement" do
    assert_difference("FinancialMovement.count") do
      post financial_movements_url, params: { financial_movement: { amount: @financial_movement.amount, category: @financial_movement.category, date: @financial_movement.date, description: @financial_movement.description, type: @financial_movement.type, user_id: @financial_movement.user_id } }
    end

    assert_redirected_to financial_movement_url(FinancialMovement.last)
  end

  test "should show financial_movement" do
    get financial_movement_url(@financial_movement)
    assert_response :success
  end

  test "should get edit" do
    get edit_financial_movement_url(@financial_movement)
    assert_response :success
  end

  test "should update financial_movement" do
    patch financial_movement_url(@financial_movement), params: { financial_movement: { amount: @financial_movement.amount, category: @financial_movement.category, date: @financial_movement.date, description: @financial_movement.description, type: @financial_movement.type, user_id: @financial_movement.user_id } }
    assert_redirected_to financial_movement_url(@financial_movement)
  end

  test "should destroy financial_movement" do
    assert_difference("FinancialMovement.count", -1) do
      delete financial_movement_url(@financial_movement)
    end

    assert_redirected_to financial_movements_url
  end
end
