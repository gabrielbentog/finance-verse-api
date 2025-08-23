class Api::DashboardController < Api::ApiController
  def index
    year = params[:year] || Time.current.year
    month = params[:month]

    # Base query for selected period
    movements = current_api_user.movements
    movements = apply_date_filters(movements, year, month)

    # Total calculations
    income_total = movements.income.sum(:amount)
    expense_total = movements.expense.sum(:amount)
    
    # Expenses by category
    expenses_by_category = movements.expense
      .group(:category)
      .sum(:amount)
      .map { |category, value| { 
        id: category || 'Uncategorized', 
        value: value, 
        label: category || 'Uncategorized'
      }}

    # Last 3 months
    last_three_months = calculate_last_three_months

    render json: {
      data: {
        balance: income_total - expense_total,
        income: income_total,
        expenses: expense_total,
        expensesByCategory: expenses_by_category,
        lastMonths: last_three_months
      }
    }
  end

  private

  def apply_date_filters(scope, year, month)
    scope = scope.where('EXTRACT(YEAR FROM date) = ?', year) if year.present?
    scope = scope.where('EXTRACT(MONTH FROM date) = ?', month) if month.present?
    scope
  end

  def calculate_last_three_months
    end_date = Time.current.end_of_month
    start_date = (end_date - 2.months).beginning_of_month
    
    (0..2).map do |i|
      current_date = end_date - i.months
      month_start = current_date.beginning_of_month
      month_end = current_date.end_of_month
      
      month_movements = current_api_user.movements
        .where(date: month_start..month_end)
      
      {
        month: I18n.l(current_date, format: '%B/%Y'),
        income: month_movements.income.sum(:amount),
        expenses: month_movements.expense.sum(:amount)
      }
    end.reverse
  end
end
