class Api::IrpfController < Api::ApiController
  # GET /api/irpf
  # Returns KPIs and detail summary for selected year
  def index
    year = params[:year].presence || Time.current.year

    scope = current_api_user.movements
            .where(is_business: true)
            .where("EXTRACT(YEAR FROM date) = ?", year)

    gross_revenue = current_api_user.movements.where("EXTRACT(YEAR FROM date) = ?", year).where(movement_type: :income).sum(:amount)
    expenses = scope.where(movement_type: :expense).sum(:amount)
    profit = gross_revenue - expenses

    # parcela isenta — usamos a soma dos percentuais ponderada pelos lançamentos de receita
    # (simplificação: média ponderada por receita amount * exemption%)
    total_exempt_value = scope.where(movement_type: :income).sum do |m|
      (m.tax_exemption_percentage.present? ? (m.amount * m.tax_exemption_percentage / 100.0) : 0.0)
    end

    parcela_isenta_percent = 0
    parcela_isenta_value = 0
    if gross_revenue > 0
      parcela_isenta_value = total_exempt_value
      parcela_isenta_percent = (parcela_isenta_value / gross_revenue * 100.0).round(2)
    end

    # faixa e deduções são complexas; aqui devolvemos placeholders que o frontend pode usar
    render json: {
      data: {
        kpis: {
          gross_revenue: gross_revenue,
          expenses: expenses,
          profit: profit,
          estimated_irpf: 0.0
        },
        detail: {
          gross_revenue: gross_revenue,
          proved_expenses: expenses,
          real_profit: profit,
          parcela_isenta_percent: parcela_isenta_percent,
          parcela_isenta_value: parcela_isenta_value,
          taxable_profit: [profit - parcela_isenta_value, 0].max
        }
      }
    }
  end

  # GET /api/irpf/expenses
  # List business expenses for the selected year. Supports filter nf via supporting_doc_url presence
  def expenses
    year = params[:year].presence || Time.current.year
    filtro_nf = params[:nf] # 'all' | 'with' | 'without'

    scope = current_api_user.movements
            .where(is_business: true, movement_type: :expense)
            .where("EXTRACT(YEAR FROM date) = ?", year)

    scope = case filtro_nf
            when 'with'
              scope.where.not(supporting_doc_url: [nil, ''])
            when 'without'
              scope.where(supporting_doc_url: [nil, ''])
            else
              scope
            end

    results = scope.order(date: :desc).page(params.dig(:page, :number)).per(params.dig(:page, :size) || 20)

    render json: results, each_serializer: MovementSerializer, meta: generate_meta(results)
  end

  # GET /api/irpf/revenues
  def revenues
    year = params[:year].presence || Time.current.year

    scope = current_api_user.movements
            .where(movement_type: :income)
            .where("EXTRACT(YEAR FROM date) = ?", year)

    results = scope.order(date: :desc).page(params.dig(:page, :number)).per(params.dig(:page, :size) || 20)
    render json: results, each_serializer: MovementSerializer, meta: generate_meta(results)
  end

  # GET /api/reports/irpf
  # Returns a report JSON for the given year (frontend will trigger export if needed)
  def report
    year = params[:year].presence || Time.current.year
    # Reuse index to get summary
    summary = begin
      delegate = self
      # call index logic directly is a bit hacky; instead recompute minimal report
      scope = current_api_user.movements.where(is_business: true).where("EXTRACT(YEAR FROM date) = ?", year)
      gross_revenue = scope.where(movement_type: :income).sum(:amount)
      expenses = scope.where(movement_type: :expense).sum(:amount)
      profit = gross_revenue - expenses

      {
        gross_revenue: gross_revenue,
        expenses: expenses,
        profit: profit,
        movements_count: scope.count
      }
    end

    render json: { data: { year: year, report: summary } }
  end

  # POST /api/reports/irpf/export
  # Placeholder that returns a URL or triggers background job; here we return a download URL stub
  def export
    year = params[:year].presence || Time.current.year
    # In production, enqueue export job and return job id or signed URL
    render json: { data: { download_url: "https://example.com/exports/irpf_#{year}.pdf" } }
  end
end
