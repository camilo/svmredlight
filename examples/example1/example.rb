require './lib/svmredlight'
include SVMLight

# Turn a line of the example data into a useful features array
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
  if x >= 0 
    1 
  else
    -1
  end
end

training_documents_and_labels = []

puts "Reading training data..."
File.open('./examples/example1/train.dat', 'r').each_with_index do |line, i|
  next if line.chars.first == '#'
  ary, target = line_to_ary(line, true)
  training_documents_and_labels << [Document.create(i + 1, 1, 0, 1, ary), target.to_i]
end


m = Model.learn_classification(training_documents_and_labels, 
                               {'biased_hyperplane' => true, 
                                "svm_c" => 1.5}, 
                               {}, 
                               false,  
                               nil)

puts "New model created, with #{m.support_vector_count} support vectors"

hits = 0
misses = 0
total = 0

puts "Classifiying test data, correct classitication : :) incorrect : :( .\n"
File.open('./examples/example1/test.dat', 'r').each_with_index do |line, i|
  next if line.chars.first == '#'
  ary, target = line_to_ary(line, true)
  next if ary.empty?
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
