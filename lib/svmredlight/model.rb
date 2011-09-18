module SVMLight
  # A model is the product of training a SVM, once created it can take documents as inputs
  # and act of them (by for instance classifying them). Models can also be read from files
  # created by svm_learn.
  class Model
    TYPES = [:classification]

    # Learns a model from a set of labeled documents.
    # @param [Symbol] type, what kind of model is this, classification, regression, etc. for now the only valid value is classification.
    # @param [Array] documents_and_lables documents and labels is an array of arrays where each inner array must have two elements, the first, a Document and the second a classification (normally +1 and  -1)
    # @param [Hash] learn_params each key of learn_params is a string it that maps to a field of the LEARN_PARM struct in SVMLight
    # @param [Hash] kernel_params each key of kernel_params is a string it that maps to a field of the KERNEL_PARM struct in SVMLight
    # @param [Array|Nil] alphas an array of alpha values 
    def self.new(type, documents_and_lables, learn_params, kernel_params, alphas = nil )
      raise ArgumentError, "Supporte types are (for now) #{TYPES}" unless TYPES.include? type

      learn_classification(documents_and_lables, learn_params, kernel_params, false, alphas)
    end
    private_class_method :learn_classification
  end
end
