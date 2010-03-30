// Creates keys like: 
//  [ 'message-3htjp', nil ]
//

function(doc) {

  if (doc.data_model == 'Message' && doc.privacy == 'public' && doc.created_at && doc.created_at > '2010-01-01 00:00:00')
    emit( doc.created_at, 1 );

};
