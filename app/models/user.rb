class User < ActiveRecord::Base
  has_many :purchases, foreign_key: :buyer_id
  has_many :products, through: :purchases
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  # Braintree methods
  FIELDS = [:first_name, :last_name, :phone, :website, :company, :fax, :addresses, :credit_cards, :custom_fields, :purchases, :power_user]
  attr_accessor *FIELDS

  def has_payment_info?
    braintree_customer_id
  end

  def with_braintree_data!
    return self unless has_payment_info?
    braintree_data = Braintree::Customer.find(braintree_customer_id)

    FIELDS.each do |field|
      send(:"#{field}=", braintree_data.send(field))
    end
    self
  end

  def default_credit_card
    return unless has_payment_info?
    credit_cards.find { |cc| cc.default? }
  end

  # Cart methods
  def cart_count
    $redis.scard "cart#{id}"
  end

  def cart_total_price
    total_price = 0
    get_cart_products.each { |product| total_price+= product.price }
    total_price
  end

  def get_cart_products
    cart_ids = $redis.smembers "cart#{id}"
    Product.find(cart_ids)
  end

  # Purchasing methods

  def purchase_cart_products!
    get_cart_products.each { |product| }
    $redis.del "cart#{id}"
  end

  def purchase?(product)
    products.include?(product)
  end

  def purchase(product)
    products << product unless purchase?(product)
  end



end
