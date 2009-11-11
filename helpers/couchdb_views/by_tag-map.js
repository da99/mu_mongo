//
// Creates these indexes:
// [ ['pets',        '2007-04-03 11:11:02'], null ]
// [ ['hearts-pets', '2007-04-03 11:11:02'], null ]
// [ ['home-pets',   '2007-04-03 11:11:02'], null ]
// [ ['health-pets', '2007-04-03 11:11:02'], null ]
//        

function(doc) { 
  var cats = ['health', 'hearts', 'home'];
  if (doc.tags)  {
    
    for(var t in doc.tags) {

      emit([doc.tags[t], doc.published_at], null);
     
      if ( cats.indexOf( doc.tags[t] ) == -1 )
        for(var j in cats){
          if (doc.tags.indexOf( cats[j] ) > -1)
            emit([ cats[j] , doc.tags[t], doc.published_at], null);
        };

    }; // for

  }; // if

}
