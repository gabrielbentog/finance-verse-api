require "application_system_test_case"

class FinancialMovementsTest < ApplicationSystemTestCase
  setup do
    @financial_movement = financial_movements(:one)
  end

  test "visiting the index" do
    visit financial_movements_url
    assert_selector "h1", text: "Financial movements"
  end

  test "should create financial movement" do
    visit financial_movements_url
    click_on "New financial movement"

    fill_in "Amount", with: @financial_movement.amount
    fill_in "Category", with: @financial_movement.category
    fill_in "Date", with: @financial_movement.date
    fill_in "Description", with: @financial_movement.description
    fill_in "Type", with: @financial_movement.type
    fill_in "User", with: @financial_movement.user_id
    click_on "Create Financial movement"

    assert_text "Financial movement was successfully created"
    click_on "Back"
  end

  test "should update Financial movement" do
    visit financial_movement_url(@financial_movement)
    click_on "Edit this financial movement", match: :first

    fill_in "Amount", with: @financial_movement.amount
    fill_in "Category", with: @financial_movement.category
    fill_in "Date", with: @financial_movement.date
    fill_in "Description", with: @financial_movement.description
    fill_in "Type", with: @financial_movement.type
    fill_in "User", with: @financial_movement.user_id
    click_on "Update Financial movement"

    assert_text "Financial movement was successfully updated"
    click_on "Back"
  end

  test "should destroy Financial movement" do
    visit financial_movement_url(@financial_movement)
    click_on "Destroy this financial movement", match: :first

    assert_text "Financial movement was successfully destroyed"
  end
end
