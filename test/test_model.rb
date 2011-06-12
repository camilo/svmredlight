require './test/helper'
require './lib/svmredlight'

class TestModel < Test::Unit::TestCase
  def test_read
    assert m = Model.read_from_file('test/model')
    assert_equal 3877, m.support_vector_count
    assert_equal 39118, m.total_words
  end

  def test_classify
    m = Model.read_from_file('test/model')
    assert m.classify( Document.create(-1, 0, [1.0, 0, 0, 0, 0.5 ])) 
    assert m.classify( Document.create(-1, 0, [0, 0, 0, 0, 0.8, 0, 0 , 0 ])) 
    assert m.classify( Document.create(-1, 0, [0, 0.5, 0, 0, 0, 0 , 0 ])) 
  end

  def test_new_is_private
    assert_raise(NoMethodError){ Model.new }
  end
end

