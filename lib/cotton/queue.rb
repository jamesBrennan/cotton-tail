# frozen_string_literal: true

module Cotton
  # Simple Queue strategy
  class Queue
    def self.call(_name)
      ::Queue.new
    end
  end
end
