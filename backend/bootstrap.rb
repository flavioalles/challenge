class Payment
  attr_reader :authorization_number, :amount, :invoice, :order, :payment_method, :paid_at

  def initialize(attributes = {})
    @authorization_number, @amount = attributes.values_at(:authorization_number, :amount)
    @invoice, @order = attributes.values_at(:invoice, :order)
    @payment_method = attributes.values_at(:payment_method)
  end

  def pay(paid_at = Time.now)
    @amount = order.total_amount
    @authorization_number = Time.now.to_i
    @invoice = Invoice.new(billing_address: order.address, shipping_address: order.address, order: order)
    @paid_at = paid_at
    order.close(@paid_at)
  end

  def paid?
    !paid_at.nil?
  end
end

class Invoice
  attr_reader :billing_address, :shipping_address, :order

  def initialize(attributes = {})
    @billing_address = attributes.values_at(:billing_address)
    @shipping_address = attributes.values_at(:shipping_address)
    @order = attributes.values_at(:order)
  end
end

class Order
  attr_reader :customer, :items, :payment, :address, :closed_at

  def initialize(customer, overrides = {})
    @customer = customer
    @items = []
    @order_item_class = overrides.fetch(:item_class) { OrderItem }
    @address = overrides.fetch(:address) { Address.new(zipcode: '45678-979') }
  end

  def add_product(product)
    @items << @order_item_class.new(order: self, product: product)
  end

  def total_amount
    @items.map(&:total).inject(:+)
  end

  def close(closed_at = Time.now)
    @closed_at = closed_at
  end

  def process
    # process every item in order associated with order
    @items.each do |item|
      item.product.process
    end
  end
end

class OrderItem
  attr_reader :order, :product

  def initialize(order:, product:)
    @order = order
    @product = product
  end

  def total
    return product.price
  end
end

class Product
  attr_reader :name, :price

  def initialize(name, price)
    @name = name
    @price = price
  end
end

class Physical < Product
  def initialize(name:, price:)
    super(name, price)
  end

  def process
    # generate shipping label
    puts "#{self.class}: Generate shipping label."
  end
end

class Book < Product
  def initialize(name:, price:)
    super(name, price)
  end

  def process
    # generate special shipping label
    puts "#{self.class}: Generate special shipping label."
  end
end

class Digital < Product
  def initialize(name:, price:)
    super(name, price)
  end

  def process
    # email item description
    puts "#{self.class}: Email item description."
    # generate R$ 10 discount voucher
    puts "#{self.class}: Generate R$ 10 discount voucher."
  end
end

class Membership < Product
  def initialize(name:, price:)
    super(name, price)
  end

  def process
    # activate subscription
    puts "#{self.class}: Activate subscription."
    # email user
    puts "#{self.class}: Email user subscription info."
  end
end

class Address
  attr_reader :zipcode

  def initialize(zipcode:)
    @zipcode = zipcode
  end
end

class CreditCard
  def self.fetch_by_hashed(code)
    CreditCard.new
  end
end

class Customer
  attr_reader :name, :id, :dob

  def initialize(name, id, dob)
    @name = name
    @id = id
    @dob = dob # date of birth
  end
end
