# frozen_string_literal: true

module CottonTail
  module Queue
    # Simple in-memory queue
    class Memory
      def self.call(**_kwargs)
        ::Queue.new
      end
    end
  end
end
