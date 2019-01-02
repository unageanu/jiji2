# frozen_string_literal: true

require 'jiji/test/test_configuration'

class TestModelA

  include Mongoid::Document
  include Jiji::Utils::BulkWriteOperationSupport

  store_in collection: 'test_model_a'

  field :name,      type: String
  field :timestamp, type: Time

end

class TestModelB

  include Mongoid::Document
  include Jiji::Utils::BulkWriteOperationSupport

  store_in collection: 'test_model_b'
  belongs_to :test_model_a

  field :name,      type: String
  field :value,     type: Integer

end

describe Jiji::Utils::BulkWriteOperationSupport do
  before(:example) do
  end

  after(:example) do
    TestModelB.delete_all
    TestModelA.delete_all
  end

  it 'トランザクション内で行われた更新を記録し、一括登録できる' do
    expect(all_names_of_a).to eq []
    expect(all_names_of_b).to eq []

    Jiji::Utils::BulkWriteOperationSupport.begin_transaction

    a1 = TestModelA.new
    a1.name = 'a1'
    a2 = TestModelA.new
    a2.name = 'a2'
    a1.save
    a2.save

    b1 = TestModelB.new
    b1.name = 'b1'
    b1.test_model_a = a1
    b2 = TestModelB.new
    b2.name = 'b2'
    b2.test_model_a = a2
    b1.save
    b2.save

    expect(all_names_of_a).to eq []
    expect(all_names_of_b).to eq []

    expect(Jiji::Utils::BulkWriteOperationSupport.transaction.size).to eq 4

    Jiji::Utils::BulkWriteOperationSupport.end_transaction

    expect(all_names_of_a).to eq %w[a1 a2]
    expect(all_names_of_b).to eq %w[b1 b2]
  end

  it '永続化の順番が前後しても、親から順にソートして永続化できる' do
    expect(all_names_of_a).to eq []
    expect(all_names_of_b).to eq []

    Jiji::Utils::BulkWriteOperationSupport.begin_transaction

    a1 = TestModelA.new
    a1.name = 'a1'
    a2 = TestModelA.new
    a2.name = 'a2'

    b1 = TestModelB.new
    b1.name = 'b1'
    b1.test_model_a = a1
    b2 = TestModelB.new
    b2.name = 'b2'
    b2.test_model_a = a2
    b1.save
    b2.save

    a1.save
    a2.save

    expect(all_names_of_a).to eq []
    expect(all_names_of_b).to eq []

    expect(Jiji::Utils::BulkWriteOperationSupport.transaction.size).to eq 4

    Jiji::Utils::BulkWriteOperationSupport.end_transaction

    expect(all_names_of_a).to eq %w[a1 a2]
    expect(all_names_of_b).to eq %w[b1 b2]
  end

  it '永続化済みドキュメントのupdateができる' do
    a1 = TestModelA.new
    a1.name = 'a1'
    a1.save
    b1 = TestModelB.new
    b1.name = 'b1'
    b1.test_model_a = a1
    b1.save

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    Jiji::Utils::BulkWriteOperationSupport.begin_transaction

    a2 = TestModelA.new
    a2.name = 'a2'
    a2.save

    b2 = TestModelB.new
    b2.name = 'b2'
    b2.test_model_a = a2
    b2.save

    a1.name = 'a1_2'
    b1.name = 'b1_2'
    a1.save
    b1.save

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    expect(Jiji::Utils::BulkWriteOperationSupport.transaction.size).to eq 4

    Jiji::Utils::BulkWriteOperationSupport.end_transaction

    expect(all_names_of_a).to eq %w[a1_2 a2]
    expect(all_names_of_b).to eq %w[b1_2 b2]
  end

  it '複数回saveを呼び出しても、永続化は1度だけ行われる' do
    a1 = TestModelA.new
    a1.name = 'a1'
    a1.save
    b1 = TestModelB.new
    b1.name = 'b1'
    b1.test_model_a = a1
    b1.save

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    Jiji::Utils::BulkWriteOperationSupport.begin_transaction

    a2 = TestModelA.new
    a2.name = 'a2'
    a2.save
    a2.save
    a2.save

    b2 = TestModelB.new
    b2.name = 'b2'
    b2.test_model_a = a2
    b2.save
    b2.save
    b2.save

    a1.name = 'a1_2'
    b1.name = 'b1_2'
    a1.save
    b1.save
    a1.save
    b1.save

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    expect(Jiji::Utils::BulkWriteOperationSupport.transaction.size).to eq 4

    Jiji::Utils::BulkWriteOperationSupport.end_transaction

    expect(all_names_of_a).to eq %w[a1_2 a2]
    expect(all_names_of_b).to eq %w[b1_2 b2]
  end

  it '更新がない場合、何もしない' do
    a1 = TestModelA.new
    a1.name = 'a1'
    a1.save
    b1 = TestModelB.new
    b1.name = 'b1'
    b1.test_model_a = a1
    b1.save

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    Jiji::Utils::BulkWriteOperationSupport.begin_transaction

    a1.save
    b1.name = 'b1_2'

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']

    expect(Jiji::Utils::BulkWriteOperationSupport.transaction.size).to eq 1

    Jiji::Utils::BulkWriteOperationSupport.end_transaction

    expect(all_names_of_a).to eq ['a1']
    expect(all_names_of_b).to eq ['b1']
  end

  it '#in_transaction?' do
    expect(Jiji::Utils::BulkWriteOperationSupport.in_transaction?).to be false
    Jiji::Utils::BulkWriteOperationSupport.begin_transaction
    expect(Jiji::Utils::BulkWriteOperationSupport.in_transaction?).to be true
    Jiji::Utils::BulkWriteOperationSupport.end_transaction
    expect(Jiji::Utils::BulkWriteOperationSupport.in_transaction?).to be false
  end

  def all_names_of(model_class)
    model_class.all.map { |m| m.name }.sort
  end

  def all_names_of_a
    all_names_of(TestModelA)
  end

  def all_names_of_b
    all_names_of(TestModelB)
  end
end
