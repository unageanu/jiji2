# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Utils::ValueObject do
  class ClassA

    include Jiji::Utils::ValueObject

    attr_writer :string, :number, :object, :array, :hash

    def initialize(string, number, object, array, hash)
      @string = string
      @number = number
      @object = object
      @array  = array
      @hash   = hash
    end

    protected

    def values
      [@string, @number, @object, @array, @hash]
    end

  end

  class ClassB

    include Jiji::Utils::ValueObject

    attr_writer :string, :number, :object, :array, :hash

    def initialize(string, number, object, array, hash)
      @string = string
      @number = number
      @object = object
      @array  = array
      @hash   = hash
    end

  end

  shared_examples 'valueオブジェクトの仕様' do
    it 'to_h ですべてのインスタンス変数を保持するハッシュに変換できる' do
      object = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      hash   = object.to_h

      expect(hash).to eq({
        string: 'o',
        number: 100,
        object: nil,
        array:  [1, 2, 3],
        hash:   {
          a: 'b',
          b: 10
        }
      })
    end

    it 'from_h でハッシュから値を読み込める' do
      object = @cl.new('', 99, nil, [3, 2, 3], a: 'x', b: 10)
      object.from_h({
        string: 'o',
        number: 100,
        object: nil,
        array:  [1, 2, 3],
        hash:   {
          a: 'b',
          b: 10
        }
      })
      expect(object).to eq(
        @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10))
    end

    it '同じオブジェクトの場合、 ==, eql, hash は同じになる' do
      object1 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object2 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)

      a = @cl.new('a', 1, object1, [1, 2, object1], a: 'b', b: object1)
      b = @cl.new('a', 1, object2, [1, 2, object2], a: 'b', b: object2)

      expect_objects_are_equal(a, b)
    end

    it '違うオブジェクトの場合、 ==, eql, hash は違う値になる' do
      object1 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object2 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object3 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object4 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object5 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)
      object6 = @cl.new('o', 100, nil, [1, 2, 3], a: 'b', b: 10)

      a = @cl.new('a', 1, object1, [1, 2, object3], a: 'b', b: object5)
      b = @cl.new('a', 1, object2, [1, 2, object4], a: 'b', b: object6)

      expect_objects_are_equal(a, b)

      a.string = 'b'
      expect_objects_are_not_equal(a, b)

      a.string = 'a'
      a.number = 2
      expect_objects_are_not_equal(a, b)

      a.number = 1
      object1.string = 'oo'
      expect_objects_are_not_equal(a, b)

      object1.string = 'o'
      a.array = [1, 2]
      expect_objects_are_not_equal(a, b)

      a.array = [1, 2, object3]
      a.hash = { a: 'c', b: object5 }
      expect_objects_are_not_equal(a, b)

      a.hash = { a: 'b', b: object5 }
      object3.string = 'oo'
      expect_objects_are_not_equal(a, b)

      object3.string = 'o'
      object5.string = 'oo'
      expect_objects_are_not_equal(a, b)

      object5.string = 'o'
      expect_objects_are_equal(a, b)
    end
  end

  context 'values をオーバーライドする場合' do
    before do
      @cl = ClassA
    end

    it_behaves_like 'valueオブジェクトの仕様'
  end

  context 'values をオーバーライドしない場合' do
    before do
      @cl = ClassB
    end

    it_behaves_like 'valueオブジェクトの仕様'
  end

  def expect_objects_are_equal(a, b)
    expect(a.eql?(b)).to be true
    expect(a == b).to be true
    expect(a.hash == b.hash).to be true
  end

  def expect_objects_are_not_equal(a, b)
    expect(a.eql?(b)).to be false
    expect(a == b).to be false
    expect(a.hash == b.hash).to be false
  end
end
