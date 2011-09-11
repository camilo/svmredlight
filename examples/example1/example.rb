require './lib/svmredlight'
include SVMLight

# This is the canonical example referenced in [http://svmlight.joachims.org/]. This ruby
# version will read the included train file, generate a set of labeled documents and
# train a new model based on it. 
#
# Then it will read the test set, classify every document and report how many documents in
# the training set were correctly classified and missed.

# Turn a line of the example data into an useful features array
def line_to_ary(line, has_target = false)
  records = line.split(' ')
  target =  records.shift if has_target

  ary = []

  records.each_with_index do |record, i|
    pos, value = record.split(':')
    ary << [pos.to_i, value.to_f]
  end

  [ary, target]
end

# Quick sign function
def sign(x)
  x >= 0 ? 1  : -1
end

puts "Reading training data..."
training_documents_and_labels = []

File.open('./examples/example1/train.dat', 'r').each_with_index do |line, i|
  next if line.chars.first == '#'
  ary, target = line_to_ary(line, true)
  training_documents_and_labels << [Document.create(i + 1, 1, 0, 1, ary), target.to_i]
end

# Train a model here, you can play with the available learn_params
m = Model.new(:classification,                 # type
               training_documents_and_labels,  # set of labeled documents
               {'biased_hyperplane' => true, 'svm_c' => 1.5}, # learn_params
               {},                                            # kernel_params
               nil)                                           # alpha values

puts "New model created, with #{m.support_vectors_count} support vectors"

hits = 0
misses = 0
total = 0

# Try the new model out against the test file.
puts "Classifiying test data, correct classitication : :) incorrect : :( .\n"
File.open('./examples/example1/test.dat', 'r').each_with_index do |line, i|
  next if line.chars.first == '#'
  ary, target = line_to_ary(line, true)
  next if ary.empty?
  
  # Classify an unknown document using the model
  result = m.classify(Document.create(i + 1, 1, 0, 1, ary)) 

  total += 1

  if sign(result) == target.to_i
    print ':) '
    hits += 1
  else
    print ':( '
    misses += 1
  end

end

puts "\nResults"
puts "Correctly classified #{hits} of #{total} examples in the test set."
