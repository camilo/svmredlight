require 'mkmf'
have_header("svm_light/svm_common.h")
have_library("svmlight")
$objs = %w{svmredlight.o}
create_makefile('svmredlight')

