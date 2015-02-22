require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

class Parent
  include Mongoid::Document

  store_in collection: 'xxx'

  field :parent_id,        type: Symbol
end

class ChildA < Parent
  field :v1,        type: Symbol
end

class ChildB < Parent
  field :v2,        type: Symbol
end

describe 'Mongoid' do
  it 'モデルの継承ができる' do
    a = ChildA.new
    a.parent_id = :a
    a.v1 = :a
    a.save

    b = ChildB.new
    b.parent_id = :b
    b.v2 = :b
    b.save

    expect(ChildA.find_by(parent_id: :a)).to_not be nil
    expect(ChildA.find_by(parent_id: :b)).to be nil
    expect(Parent.find_by(parent_id: :a)).to_not be nil

    Parent.delete_all
  end
end
