require 'spec_helper'

def class_builder(field, message)
  test_class = Class.new do
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    validates_presence_of field, :message => message
    attr_accessor field

    def initialize(attributes={})
      attributes.each do |name, value|
        send("#{name}", value)
      end
    end

    def persisted?
      false;
    end

    def self.model_name
      ActiveModel::Name.new(Class)
    end

  end

  return test_class.new
end



describe CustomErrorMessage do

  it 'without a caret, should not change behavior' do
    @model = class_builder(:email, 'is not present')
    @model.valid?
    @model.errors.full_messages.should include("Email is not present")
  end

  it 'with a caret, should allow for custom message' do
    @model = class_builder(:email, "Please provide an email address")
    @model.valid?
    @model.errors.full_messages.should include("Please provide an email address")
  end
end


