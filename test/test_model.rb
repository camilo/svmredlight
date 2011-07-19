require './test/helper'
include SVMLight

class TestModel < Test::Unit::TestCase

  def setup
    @docs_and_labels = 
     [[ Document.create(-1, 0, [1,1]  ), 1.0 ],
      [ Document.create(-1, 0, [-1,-1]), 0.0 ],
      [ Document.create(-1, 0, [-1,-1]), 0.0 ],
      [ Document.create(-1, 0, [1,1]  ), 1.0 ],
      [ Document.create(-1, 0, [1,1]  ), 1.0 ],]
  end

  def test_new_is_private
    assert_raise(NoMethodError){ Model.new }
  end

  def test_learn_classification_with_alpha
    m = Model.learn_classification(@docs_and_labels, {}, {}, true, [1, 0.0, 1])
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end

  def test_learn_classification
    m = Model.learn_classification(@docs_and_labels, {}, {}, true, nil)
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end

  end

  def test_learn_classification_with_learn_params
    
    learn_params = {
       "predfile"            => "omg",
       "alphafile"           => "alpha",
       "biased_hyperplane"   => true,
       "sharedslack"         => true,
      # TODO test when this is true it is hanging the learning for some reason
      # "remove_inconsistent" => true
    }

    m = Model.learn_classification(@docs_and_labels, learn_params, {}, true, nil)
                                   #, [1, 0.0, 1])
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end

  def test_learn_classification_with_kernel_params
    
    kernel_params = {
      "poly_degree" => 50,
      "rbf_gamma"   => 0.5,
      "coef_lin"    => 0.4,
      "coef_const"  => 0.56
    }

    m = Model.learn_classification(@docs_and_labels, {}, kernel_params, true, nil)
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end
  
  def test_learn_classification_with_learn_params_when_predfile_is_not_string
    
    learn_params = { "predfile"  => {}}
  
    assert_raise(ArgumentError) do
      Model.learn_classification(@docs_and_labels, learn_params, {}, true, [1, 0.0, 1])
    end

  end

  def test_learn_classification_fails_when_element_is_not_array
    @docs_and_labels << []
    assert_raises(ArgumentError){Model.learn_classification(@docs_and_labels, {}, {}, true, nil)}
  end

  def test_learn_classification_fails_when_element_is_arry_with_the_wrong_types
    assert_raises(ArgumentError){Model.learn_classification(@docs_and_labels, {}, {}, true, [1, {}] )}
  end

  def test_read
    assert m     = Model.read_from_file('test/assets/model')
    assert_equal 3877, m.support_vector_count
    assert_equal 39118, m.total_words
  end

  def test_classify
    m = Model.read_from_file('test/assets/model')
    assert_kind_of Numeric, m.classify( Document.create(-1, 0, [1.0, 0, 0, 0, 0.5 ]))
    assert_kind_of Numeric, m.classify( Document.create(-1, 0, [1.0, 0, 0, 0, 0.5 ]))
    assert_kind_of Numeric, m.classify( Document.create(-1, 0, [0, 0, 0, 0, 0.8, 0, 0 , 0 ]))
    assert_kind_of Numeric, m.classify( Document.create(-1, 0, [0, 0.5, 0, 0, 0, 0 , 0 ]))
  end


#  This might kill your machine or at least keep it occupied for a long time, there has to
#  be a way to optimize the loop extracting features, but even then chances are it will
#  take a while, another option if you really want to run this tests is to recompile and
#  deifine a much smaller MAXFEATNUM
# def test_learn_classification_fails_when_more_than_max_feature
#   # Testing against a MAXFEATNUM = 99999999
#   d = Document.create(-1, 0, [1] * (99999999 + 1) )
#   @docs_and_labels << [d, 1.0]
#   Model.learn_classification(@docs_and_labels, {}, {}, false, nil)
# end
end

