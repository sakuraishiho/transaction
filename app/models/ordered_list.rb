class OrderedList < ApplicationRecord
  belongs_to :order
  belongs_to :item
  # スコープを定義してロックをかける
  scope :lock_for_update, -> { lock('FOR UPDATE') }

  # 注文処理をトランザクション内で行う
  def self.place_order(order_id:, item_id:, quantity:)
    ActiveRecord::Base.transaction do
      # FOR UPDATEでロックをかけて商品に対する他の注文をブロック
      ordered_list = OrderedList.lock_for_update.find_or_create_by(order_id: order_id, item_id: item_id)
      # 注文数を加算
      ordered_list.quantity += quantity
      ordered_list.save!
    end
  end
end
