# frozen_string_literal: true

module CottonTail
  # Queue namespace
  module Queue
    autoload :Bunny, 'cotton_tail/queue/bunny'
    autoload :Connection, 'cotton_tail/queue/connection'
    autoload :Memory, 'cotton_tail/queue/memory'
    autoload :Reader, 'cotton_tail/queue/reader'
    autoload :Supervisor, 'cotton_tail/queue/supervisor'
  end
end
