class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :purchases, foreign_key: :buyer_id
  has_many :products, through: :purchases

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def cart_count
    $redis.scard "cart#{id}"
  end

  def cart_total_price
    total_price = 0
    get_cart_products.each { |product| total_price += product.price }
    total_price
  end

  def get_cart_products
    cart_ids = $redis.smembers "cart#{id}"
    Product.find(cart_ids)
  end

  def purchase_cart_products!
    get_cart_products.each { |product| purchase(product) }
    $redis.del "cart#{id}"
  end

  def purchase(product)
    products << product unless purchase?(product)
  end

  def purchase?(product)
    products.include?(product)
  end

  def has_payment_info?
    braintree_customer_id
  end

end
