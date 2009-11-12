// Creates keys like:
//  [ 'mem-guid-10',  'username-id-4']
//  [ 'mem-guid-100', 'username-id-20']
//  [ 'mem-guid-100', 'username-id-29']

function(doc) {
  if (doc.data_model == 'Username' && doc.owner_id && doc.username)
    emit( doc.owner_id, doc.username );
};
