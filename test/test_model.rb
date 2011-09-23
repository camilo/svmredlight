require './test/helper'
include SVMLight

class TestModel < Test::Unit::TestCase

  context "reading a model from file" do

    setup do 
      @file_name = 'test/assets/model'
    end

    should "read properly from a well formed file" do
      assert m     = Model.read_from_file(@file_name)
      assert_equal 3877,  m.support_vectors_count
      assert_equal 39118, m.total_words
    end

    should "classify successfully after reading the model from a file" do
      m = Model.read_from_file(@file_name)
      assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1.0, 0, 0, 0, 0.5 ].each_with_index.map{|v, i| [i + 1 ,v.to_f]} ) )
      assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1.0, 0, 0, 0, 0.5 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
      assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1, 0, 0, 0, 0.8, 0, 0 , 0 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
      assert_kind_of Numeric, m.classify( Document.create(-1, 1, 0, 0,[1, 0.5, 0, 0, 0, 0 , 0 ].each_with_index.map{|v, i| [i + 1,v.to_f]}) )
    end

    should "raise file not found exception when file does not exists" do
      assert_raises(MissingModelFile){ Model.read_from_file(@file_name + 'bleh') }
    end
  end

  context "writting a model to a file" do 
    setup do
      @features ||= [
        [ [1,0.6], [11, 0.0], [34, 0.1] ],
        [ [5,0.4], [15, 0.0], [30, 0.1] ],
        [ [1,0.1], [13, 0.0], [31, 0.1] ],
        [ [7,0.7], [15, 0.0], [35, 0.1] ],
        [ [5,0.6], [19, 0.0], [44, 0.1] ],
      ]

      @docs_and_labels ||= @features.each_with_index.map do |feature, index| 
        [ Document.create(index + 1, 1, 0, 0,  feature), index%2 * -1]
      end

      @filepath = './test/assets/written_model'
      @model    = Model.new(:classification, @docs_and_labels, {}, {}, nil)
    end

    should "write a model from memmory to a file" do
      @model.write_to_file(@filepath)

      assert File.exists?(@filepath)
      assert File.file?(@filepath)
      # TODO: Implement actual model equality
      assert_equal @model.support_vectors_count, Model.read_from_file(@filepath).support_vectors_count
    end

    # Need to find a good way to test this without relaying too much in the environment
    should "raise ModelWriteError when it is impossible to write a model file" 

    teardown do
      `rm #{@filepath} &> /dev/null`
    end
  end

  context "when learning from new documents" do

    setup do
      @features ||= [
        [ [1,0.6], [11, 0.0], [34, 0.1] ],
        [ [5,0.4], [15, 0.0], [30, 0.1] ],
        [ [1,0.1], [13, 0.0], [31, 0.1] ],
        [ [7,0.7], [15, 0.0], [35, 0.1] ],
        [ [5,0.6], [19, 0.0], [44, 0.1] ],
      ]

      @docs_and_labels ||= @features.each_with_index.map do |feature, index| 
        [ Document.create(index + 1, 1, 0, 0,  feature), index%2 * -1]
      end
    end

    should "learn classification with default arguments" do
      m = Model.new(:classification, @docs_and_labels, {}, {}, nil)
      assert_kind_of Model, m
      assert_equal 44, m.total_words
      assert_equal 5, m.totdoc

      @docs_and_labels.each_with_index do |item, i|
        assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
      end
    end

    should "learn classification with alpha values" do
      m = Model.new(:classification, @docs_and_labels, {}, {}, [1, 0.0] * 50)
      assert_kind_of Model, m

      @docs_and_labels.each_with_index do |item, i|
        assert_kind_of  Numeric, m.classify(item.first), "failed in item # #{i}"
      end
    end

    should "raise argument error when one of the alphas is not numeric " do 
      assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, {}, {}, [1, {}] )}
    end

    should "learn classification and accept learn parameters" do
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

    should "raise argument error when learn parameters are invalid" do
      learn_params = {"svm_c" =>  -1}
      assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, learn_params, {}, nil)}
      learn_params = {"svm_iter_to_shrink" =>  -1}
      assert_raises(ArgumentError){Model.new(:classification, @docs_and_labels, learn_params, {}, nil)}
    end

    should "learn calssification while accepting kernel paramters" do

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

    should "raise argument error when predfile is not string" do

      learn_params = { "predfile"  => {}}

      assert_raise(ArgumentError) do
        Model.new(:classification, @docs_and_labels, learn_params, {}, [1, 0.0, 1])
      end
    end

  end
end

