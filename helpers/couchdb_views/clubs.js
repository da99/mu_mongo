// Creates keys like: 
//  [ 'club-something', 'something' ]
//

function(doc) {

  if (doc.data_model == 'Club')
    emit( doc._id, doc.filename);

};
