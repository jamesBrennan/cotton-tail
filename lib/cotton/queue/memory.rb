# frozen_string_literal: true

module Cotton
  module Queue
    # Simple in-memory queue
    class Memory
      def self.call(_name)
        ::Queue.new
      end
    end
  end
end
