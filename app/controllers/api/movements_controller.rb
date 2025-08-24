class Api::MovementsController < Api::ApiController
  require 'roo'
  
  before_action :set_movement, only: [:show, :update, :destroy]

  def index
    movements = current_api_user.movements.apply_filters(params)
    
    extra_meta = {
      total_amount: current_api_user.movements.apply_filters(params.except(:page)).sum(:amount)
    }

    @meta = generate_meta(movements, extra: extra_meta)

    render json: movements, 
           each_serializer: MovementSerializer, 
           meta: @meta, 
           status: :ok
  end

  def show
    render json: @movement, serializer: MovementSerializer
  end

  def create
    movement = current_api_user.movements.new(movement_params)

    if movement.save
      render json: movement, serializer: MovementSerializer, status: :created
    else
      render json: { errors: movement.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @movement.update(movement_params)
      render json: @movement, serializer: MovementSerializer
    else
      render json: { errors: @movement.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @movement.destroy
    head :no_content
  end

  # POST /api/movements/import
  def import
    return render json: { error: 'No file uploaded' }, status: :bad_request unless params[:file].present?

    begin
      spreadsheet = Roo::Spreadsheet.open(params[:file].tempfile.path)
      header = spreadsheet.row(1)
      
      # Validar cabeçalho esperado
      expected_headers = ['Data', 'Valor', 'Descrição', 'Categoria', 'Tipo']
      unless (expected_headers - header).empty?
        return render json: { error: 'Invalid file format. Expected headers: Data, Valor, Descrição, Categoria, Tipo' }, 
                      status: :unprocessable_entity
      end

      movements = []
      errors = []
      
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        
        movement = current_api_user.movements.new(
          date: parse_date(row['Data']),
          amount: row['Valor'].to_f.abs,
          description: row['Descrição'],
          category: row['Categoria'],
          title: row['Descrição'].to_s[0..50],
          movement_type: parse_movement_type(row['Tipo'])
        )

        if movement.valid?
          movements << movement
        else
          errors << { row: i, errors: movement.errors.full_messages }
        end
      end

      if errors.any?
        render json: { errors: errors }, status: :unprocessable_entity
      else
        Movement.transaction do
          movements.each(&:save!)
        end
        
        render json: { 
          message: "Successfully imported #{movements.size} movements",
          movements: movements.map { |m| MovementSerializer.new(m) }
        }, status: :ok
      end

    rescue Date::Error
      render json: { error: 'Invalid date format in file. Expected format: DD/MM/YYYY' }, 
             status: :unprocessable_entity
    rescue Roo::HeaderRowNotFoundError
      render json: { error: 'Could not find header row in file' }, 
             status: :unprocessable_entity
    rescue => e
      render json: { error: "Error processing file: #{e.message}" }, 
             status: :unprocessable_entity
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    
    # Tenta converter diferentes formatos de data
    if date_string.is_a?(String)
      Date.parse(date_string)
    elsif date_string.is_a?(Date)
      date_string
    else
      Date.strptime(date_string.to_s, '%d/%m/%Y')
    end
  end

  def parse_movement_type(type)
    return 'expense' if type.to_s.downcase.in?(['despesa', 'expense', 'saída', 'débito', 'gasto'])
    return 'income' if type.to_s.downcase.in?(['receita', 'income', 'entrada', 'crédito', 'ganho'])
    'expense' # default para segurança
  end

  def set_movement
    @movement = current_api_user.movements.find(params[:id])
  end

  def movement_params
    params.require(:movement).permit(:title, :description, :amount, :movement_type, :category, :date)
  end

  def filter_params
    params.fetch(:filter, {}).permit(:movement_type, :category, :date)
  end
end
