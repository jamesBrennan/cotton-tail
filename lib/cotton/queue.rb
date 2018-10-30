# frozen_string_literal: true

module Cotton
  # Top level namespace for Queue implementations
  module Queue
    autoload :Memory, 'cotton/queue/memory'
  end
end
