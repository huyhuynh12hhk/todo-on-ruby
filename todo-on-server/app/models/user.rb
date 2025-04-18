class User < ApplicationRecord
  has_secure_password
  validates :email, uniqueness: true, presence: true

  has_many :todos

  def as_json(opts = {})
    super(opts.merge(only: %i[id email full_name]))
  end
end
