class Todo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true

  def as_json(opts = {})
    super(opts.merge(only: %i[id title content status updated_at]))
  end
end
