/* Very partial interface to SVMLIGHT it permits loading
 * a model (pre-created with svm_learn) from a file and using
 * it from classification for examples see test.rb
 */

#include "ruby.h"
#include "svm_light/svm_common.h"

/* Helper function to determine if
 * a model uses linear kernel, this should
 * be a #define macro
 * */
int 
is_linear(MODEL *model){
  return model->kernel_parm.kernel_type == 0; 
}

//Mdule and Classes
static VALUE rb_mSvmLight;
static VALUE rb_cModel;
static VALUE rb_cDoc;

// GC functions
void 
model_free(MODEL *m){
  if(m)
    free_model(m, m->sv_num);
}

void
doc_free(DOC *d){
  if(d)
    free_example(d, 1);
}

/* Read a svm_light model from a file generated
 * by svm_learn receives the filename as argument
 * make sure the file exists before calling this!
 * otherwise exit(1) might be called 
 *
 * */
static VALUE
model_read_from_file(VALUE klass, VALUE filename){
  Check_Type(filename, T_STRING);
  MODEL *m;

  m = read_model(StringValuePtr(filename));

  if(is_linear(m))
    add_weight_vector_to_linear_model(m);

  return Data_Wrap_Struct(klass, 0, model_free, m);
}

/*
 *  Classify, gets a example (instance of Doc)
 *  and returns its classification
 */
static VALUE
model_classify_example(VALUE self, VALUE example){
  DOC *ex;
  MODEL *m;
  double result;

  Data_Get_Struct(example, DOC, ex);
  Data_Get_Struct(self, MODEL, m);
  

  /* Apparently unnecessary code 
   *
  if(is_linear(m))
    result = classify_example_linear(m, ex);
  else
  */
  
  result = classify_example(m, ex);

  //1.9.1
  //return DBL2NUM(result);
  return rb_float_new((float)result);
}

static VALUE
model_support_vector_count(VALUE self){
  MODEL *m;
  Data_Get_Struct(self, MODEL, m);

  return INT2FIX(m->sv_num);
}

static VALUE
model_total_words(VALUE self){
  MODEL *m;
  Data_Get_Struct(self, MODEL, m);

  return INT2FIX(m->totwords);
}

//TODO Change the format for words ary from [weight, weight, weight, ]
//to [[wnum, weight],  [wnum, weight] ... ]
/*
 * Creates a DOC from an array of words it also takes an id
 * -1 is normally OK for that value when using in filtering
 *  also takes the C parameter for the SVM. I'm not sure if 
 *  it matters in filtering, I'm passing the real vale now
 *  just in case.
 *
 */
static VALUE
doc_create(VALUE klass, VALUE id, VALUE cost, VALUE words_ary ){
  int long docnum;
  int i;
  double c;
  WORD *words;
  SVECTOR *vec;
  DOC *d;

  Check_Type(words_ary, T_ARRAY);

  if (RARRAY_LEN(words_ary) == 0)
    rb_raise(rb_eArgError, "Cannot create Doc from empty arrays");

  words = (WORD*) my_malloc(sizeof(WORD) * (RARRAY_LEN(words_ary) + 1));

  for(i=0; i < (int)RARRAY_LEN(words_ary); i++){
    (words[i]).wnum     = i+1;
    (words[i]).weight   = (FVAL)(NUM2DBL(RARRAY_PTR(words_ary)[i]));
  }
  words[i].wnum = 0;

  vec = create_svector(words, "", 1.0);
  c   = NUM2DBL(cost);
  docnum = FIX2INT(id);
  d = create_example(docnum, 0, c, 0, vec);

  free(words);
  return Data_Wrap_Struct(klass, 0, doc_free, d);
}

void
Init_svmredlight(){
  rb_mSvmLight = rb_define_module("SVMLight");
  rb_cModel = rb_define_class_under(rb_mSvmLight, "Model", rb_cObject);
  rb_define_singleton_method(rb_cModel, "read_from_file", model_read_from_file, 1);
  rb_define_method(rb_cModel, "support_vector_count", model_support_vector_count, 0);
  rb_define_method(rb_cModel, "total_words", model_total_words, 0);
  rb_define_method(rb_cModel, "classify", model_classify_example, 1);
  rb_cDoc = rb_define_class_under(rb_mSvmLight, "Doc", rb_cObject);
  rb_define_singleton_method(rb_cDoc, "create", doc_create, 3);
}
