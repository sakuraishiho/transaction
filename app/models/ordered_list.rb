class OrderedList < ApplicationRecord
  belongs_to :order
  belongs_to :item

  def self.place_order(order_id:, item_id:, quantity:)
    transaction do
      # 商品を悲観的ロックで取得
      item = Item.lock("FOR UPDATE").find(item_id)
      puts "Item total_quantity before: #{item.total_quantity}"

       # 商品の在庫が足りているか確認
      if item.total_quantity < quantity
        raise StandardError.new("在庫が足りません")
      end

      # 注文を取得
      existing_order = Order.find(order_id)

      # 注文アイテムを追加または更新
      ordered_list = existing_order.ordered_lists.find_or_initialize_by(item_id: item_id)
      ordered_list.quantity += quantity
      ordered_list.save!
      puts "OrderedList quantity after: #{ordered_list.quantity}"

      # 商品の数量を更新
      item.total_quantity += quantity
      item.save!
      puts "Item total_quantity after: #{item.total_quantity}"
    end
  rescue => e
    puts "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback
  end
end