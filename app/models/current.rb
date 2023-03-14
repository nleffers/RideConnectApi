# list everything needed to be tracked across the lifetime of a request
class Current < ActiveSupport::CurrentAttributes
  # track who is performing request
  attribute :driver
end
