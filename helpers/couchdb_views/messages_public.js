// Creates keys like: 
//  [ 'message-3htjp', nil ]
//

function(doc) {

  if (doc.data_model == 'Message' && doc.privacy == 'public' )
    emit( doc.created_at, 1 );

};
