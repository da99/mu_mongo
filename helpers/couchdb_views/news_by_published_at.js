//
// Creates these indexes:
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
// [ '2007-04-03 11:11:02', null ]
//        

function(doc) { 
  if (doc.data_model == 'News' && doc.published_at)  
    emit( doc.published_at, null);
};
