require './test/helper'
include SVMLight

class TestModel < Test::Unit::TestCase

  def setup
    @features ||= [
      [ [1,0.6], [11, 0.0], [34, 0.1] ],
      [ [5,0.4], [15, 0.0], [30, 0.1] ],
      [ [1,0.1], [13, 0.0], [31, 0.1] ],
      [ [7,0.7], [15, 0.0], [35, 0.1] ],
      [ [5,0.6], [19, 0.0], [44, 0.1] ],
    ]
    @docs_and_labels ||= @features.each_with_index.map{|f,i| [ Document.create(i + 1, 1, 0, 0,  f), i%2 * -1]}
  end

  def test_learn_classification_with_alpha
    m = Model.new(:classification, @docs_and_labels, {}, {}, [1, 0.0] * 50)
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end

  def test_learn_classification
    m = Model.new(:classification, @docs_and_labels, {}, {}, nil)
    assert_kind_of Model, m
    assert_equal 44, m.total_words
    assert_equal 5, m.totdoc

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end

  end

  def test_learn_classification_with_learn_params
    
    learn_params = {
       "predfile"            => "custom_file",
       "alphafile"           => "alpha",
       "biased_hyperplane"   => false,
       "sharedslack"         => false,
       "remove_inconsistent" => true
    }

    m = Model.new(:classification, @docs_and_labels, learn_params, {}, nil)
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end

  def test_learn_classification_with_invalid_learn_params
    learn_params = {"svm_c" =>  -1}
    assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, learn_params, {}, nil)}
    learn_params = {"svm_iter_to_shrink" =>  -1}
    assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, learn_params, {}, nil)}
  end

  def test_learn_classification_with_kernel_params
    
    kernel_params = {
      "poly_degree" => 3,
      "rbf_gamma"   => 0.5,
      "coef_lin"    => 0.4,
      "coef_const"  => 0.56
    }

    m = Model.new(:classification, @docs_and_labels, {}, kernel_params, nil)
    assert_kind_of Model, m

    @docs_and_labels.each_with_index do |item, i|
      assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
    end
  end
  
  def test_learn_classification_with_learn_params_when_predfile_is_not_string
    
    learn_params = { "predfile"  => {}}
  
    assert_raise(ArgumentError) do
      Model.new(:classification, @docs_and_labels, learn_params, {}, [1, 0.0, 1])
    end

  end

  def test_learn_classification_fails_when_element_is_not_array
    @docs_and_labels << []
    assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, {}, {}, nil)}
  end

  def test_learn_classification_fails_when_element_is_arry_with_the_wrong_types
    assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, {}, {}, [1, {}] )}
  end

  def test_read
    assert m     = Model.read_from_file('test/assets/model')
    assert_equal 3877,  m.support_vectors_count
    assert_equal 39118, m.total_words
  end

  def test_classify
    m = Model.read_from_file('test/assets/model')
    assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1.0, 0, 0, 0, 0.5 ].each_with_index.map{|v, i| [i + 1 ,v.to_f]} ) )
    assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1.0, 0, 0, 0, 0.5 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
    assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1, 0, 0, 0, 0.8, 0, 0 , 0 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
    assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1, 0.5, 0, 0, 0, 0 , 0 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
  end

end

