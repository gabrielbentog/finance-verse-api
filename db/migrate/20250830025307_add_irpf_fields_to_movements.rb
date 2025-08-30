class AddIrpfFieldsToMovements < ActiveRecord::Migration[8.0]
  def change
    # Campos para mapeamento IRPF (Imposto de Renda Pessoa Física)
    add_column :movements, :is_business, :boolean, default: false, comment: 'Indica se a despesa/receita está vinculada à atividade do MEI'
    add_column :movements, :activity_kind, :integer, comment: 'Tipo de atividade MEI: comercio(8), transporte(16), servicos(32)'
    add_column :movements, :tax_exemption_percentage, :decimal, precision: 5, scale: 2, comment: 'Percentual de isenção fiscal no momento do registro'
    add_column :movements, :supporting_doc_url, :string, comment: 'Link para comprovante (PDF/JPG) da despesa/receita'
  end
end
