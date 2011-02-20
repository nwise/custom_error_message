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
    def persisted?; false; end
    def self.model_name; ActiveModel::Name.new(Class); end
  end

  return test_class.new
end

def class_without_validations(field)

  test_class = Class.new do
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor field

    def initialize(attributes={})
      attributes.each do |name, value|
        send("#{name}", value)
      end
    end
    def persisted?; false; end
    def self.model_name; ActiveModel::Name.new(Class); end
  end

  return test_class.new
end

describe 'CustomErrorMessage using declarative validation' do

  it 'without a caret, should not change behavior' do
    model = class_builder :email, 'is not present'
    model.valid?
    model.errors.full_messages.should include "Email is not present"
  end

  it 'with a caret, should allow for custom message' do
    model = class_builder :email, "^Please provide an email address"
    model.valid?
    model.errors.full_messages.should include "Please provide an email address"
  end

  it 'with caret not in the beginning, should leave original behaviour' do
    model = class_builder :email, 'is not ^ present'
    model.valid?
    model.errors.full_messages.should include "Email is not ^ present"
  end
end

describe 'CustomErrorMessage using the errors.add method' do

  before :each do
    @model = class_without_validations(:name)
  end

  it 'query of error without caret should not change behavior' do
    @model.errors.add(:name, 'is too long')
    @model.errors[:name].should == ["is too long"]
  end

  it 'added error without caret should not change behavior' do
    @model.errors.add(:name, "is too long")
    @model.errors.full_messages.should include "Name is too long"
  end

  it 'query of error with caret should show the message' do
    @model.errors.add(:name, "^You forgot the name")
    @model.errors[:name].should == ["^You forgot the name"]
  end

  it 'added error with caret should only show the message' do
    @model.errors.add(:name, '^You forgot the name')
    @model.errors.full_messages.should include "You forgot the name"
  end
end

