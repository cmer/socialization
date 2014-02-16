module Socialization
  module ActiveRecordStores
    module Mixins
      module Base
        def update_counter(model, counter)
          column_name, _ = counter.first
          model.class.update_counters model.id, counter if model.respond_to?(column_name)
        end
      end
    end
  end
end
