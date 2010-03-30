// Creates keys like: 
//  [ 'club-vitamin-fanatics', '2010-01-01 01:01:20 ]
//

function(doc) {

  if (doc.data_model == 'Message' && 
      doc.privacy == 'public' && 
      doc.created_at && doc.created_at > '2010-01-01 00:00:00',
      doc.target_ids )
    for(var i in doc.target_ids)
      emit( [doc.target_ids[i], doc.created_at], 1 );

};
