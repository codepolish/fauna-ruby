module Fauna
  class Model < Resource
    def self.inherited(base)
      base.send :extend, ClassMethods

      base.send :extend, ActiveModel::Naming
      base.send :include, ActiveModel::Validations
      base.send :include, ActiveModel::Conversion

      # Callbacks support
      base.send :extend, ActiveModel::Callbacks
      base.send :include, ActiveModel::Validations::Callbacks
      base.send :define_model_callbacks, :save, :create, :update, :destroy

      # Serialization
      base.send :include, ActiveModel::Serialization
    end

    module ClassMethods
      private

      def find_by(ref, query)
        # TODO elimate direct manipulation of the connection
        response = Fauna::Client.this.connection.get(ref, query)
        response['resources'].map { |attributes| alloc(attributes) }
      rescue Fauna::Connection::NotFound
        []
      end
    end

    def save
      if valid?
        run_callbacks(:save) do
          if new_record?
            run_callbacks(:create) { super }
          else
            run_callbacks(:update) { super }
          end
        end
      else
        false
      end
    end

    def delete
      run_callbacks(:destroy) { super }
    end

    def valid?
      run_callbacks(:validate) { super }
    end

    def to_model
      self
    end
  end
end
