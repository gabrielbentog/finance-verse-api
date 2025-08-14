Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/models/**/*.rb")].each { |f| require_dependency f }

  ApplicationRecord.descendants.each do |model|
    model.include(Filterable) unless model < Filterable
  end
end
