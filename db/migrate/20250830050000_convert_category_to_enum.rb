class ConvertCategoryToEnum < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # add temporary integer column (safe: only add if missing)
    add_column :movements, :category_tmp, :integer unless column_exists?(:movements, :category_tmp)

    # map common string values to enum integers (only run if source and target columns exist)
    if column_exists?(:movements, :category) && column_exists?(:movements, :category_tmp)
      if respond_to?(:safety_assured)
        safety_assured do
          execute <<-SQL.squish
            UPDATE movements SET category_tmp =
              CASE
                WHEN lower(category) LIKE '%aliment%' THEN 0
                WHEN lower(category) LIKE '%gasolina%' OR lower(category) LIKE '%combustivel%' OR lower(category) LIKE '%posto%' THEN 1
                WHEN lower(category) LIKE '%internet%' OR lower(category) LIKE '%wifi%' THEN 2
                WHEN lower(category) LIKE '%hospedag%' OR lower(category) LIKE '%hotel%' THEN 3
                WHEN lower(category) LIKE '%marketing%' OR lower(category) LIKE '%ads%' THEN 4
                WHEN lower(category) LIKE '%aluguel%' THEN 5
                WHEN lower(category) LIKE '%material%' OR lower(category) LIKE '%suprimentos%' THEN 6
                WHEN lower(category) LIKE '%faculdade%' OR lower(category) LIKE '%curso%' THEN 7
                WHEN lower(category) LIKE '%saude%' OR lower(category) LIKE '%medic%' THEN 8
                ELSE 99
              END;
          SQL
        end
      else
        execute <<-SQL.squish
          UPDATE movements SET category_tmp =
            CASE
              WHEN lower(category) LIKE '%aliment%' THEN 0
              WHEN lower(category) LIKE '%gasolina%' OR lower(category) LIKE '%combustivel%' OR lower(category) LIKE '%posto%' THEN 1
              WHEN lower(category) LIKE '%internet%' OR lower(category) LIKE '%wifi%' THEN 2
              WHEN lower(category) LIKE '%hospedag%' OR lower(category) LIKE '%hotel%' THEN 3
              WHEN lower(category) LIKE '%marketing%' OR lower(category) LIKE '%ads%' THEN 4
              WHEN lower(category) LIKE '%aluguel%' THEN 5
              WHEN lower(category) LIKE '%material%' OR lower(category) LIKE '%suprimentos%' THEN 6
              WHEN lower(category) LIKE '%faculdade%' OR lower(category) LIKE '%curso%' THEN 7
              WHEN lower(category) LIKE '%saude%' OR lower(category) LIKE '%medic%' THEN 8
              ELSE 99
            END;
        SQL
      end
    end

    # remove old string column and rename tmp to category (safe checks to avoid duplicate/missing column errors)
    if column_exists?(:movements, :category)
      if respond_to?(:safety_assured)
        safety_assured { remove_column :movements, :category }
      else
        remove_column :movements, :category
      end
    end

    if column_exists?(:movements, :category_tmp) && !column_exists?(:movements, :category)
      if respond_to?(:safety_assured)
        safety_assured { rename_column :movements, :category_tmp, :category }
      else
        rename_column :movements, :category_tmp, :category
      end
    end
  end

  def down
    # revert: add back string column and try to map integers to strings (only add if missing)
    add_column :movements, :category_old, :string unless column_exists?(:movements, :category_old)

    if column_exists?(:movements, :category) && column_exists?(:movements, :category_old)
      execute <<-SQL.squish
        UPDATE movements SET category_old =
          CASE category
            WHEN 0 THEN 'Alimentacao'
            WHEN 1 THEN 'Transporte'
            WHEN 2 THEN 'Internet'
            WHEN 3 THEN 'Hospedagem'
            WHEN 4 THEN 'Marketing'
            WHEN 5 THEN 'Aluguel'
            WHEN 6 THEN 'Materiais'
            WHEN 7 THEN 'Educacao'
            WHEN 8 THEN 'Saude'
            ELSE 'Outro'
          END;
      SQL
    end

    if column_exists?(:movements, :category)
      if respond_to?(:safety_assured)
        safety_assured { remove_column :movements, :category }
      else
        remove_column :movements, :category
      end
    end

    if column_exists?(:movements, :category_old) && !column_exists?(:movements, :category)
      if respond_to?(:safety_assured)
        safety_assured { rename_column :movements, :category_old, :category }
      else
        rename_column :movements, :category_old, :category
      end
    end
  end
end
