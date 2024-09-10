class OrderedList < ApplicationRecord
  belongs_to :order
  belongs_to :item
  # スコープを定義してロックをかける
  scope :lock_for_update, -> { lock('FOR UPDATE') }

end
