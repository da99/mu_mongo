//
// Creates these indexes:
// [ 'pets',   1 ]
// [ 'hearts', 2 ]
// [ 'home',   3 ]
// [ 'health', 4 ]
//        

function(doc) { 
  if (doc.data_model == 'News' && doc.tags)
    for(var t in doc.tags)
      emit(doc.tags[t], 1);
};
