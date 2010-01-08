// Creates keys like: 
//  [ 'club-something', { 'filename' : ... } ]
//

function(doc) {

  if (doc.data_model == 'Club')
    emit( doc._id, { 'filename' : doc.filename, 'title' : doc.title, 'lang' : doc.lang } );

};
