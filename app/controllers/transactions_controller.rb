class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_cart

  def new
    gon.client_token = generate_client_token
  end

  def create
    @result = Braintree::Transaction.sale(
              amount: current_user.cart_total_price,
              payment_method_nonce: params[:payment_method_nonce])
    if @result.success?
      current_user.purchase_cart_products!
      redirect_to root_url, notice: "Congraulations! You've purchased some stuff successfully!"
    else
      flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
      gon.client_token = generate_new_client_token
      render :new
    end
  end

  private

  def generate_client_token
    if current_user.has_payment_info?
      Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else
      Braintree::ClientToken.generate
    end
  end

  def check_cart
    if current_user.get_cart_products.blank?
      redirect_to root_url, alert: "Please add some items to your cart before processing your transaction!"
    end
  end

end
