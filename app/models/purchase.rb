class Purchase < ApplicationRecord

  belongs_to :products
  belongs_to :buyer, class_name: 'User'

end
