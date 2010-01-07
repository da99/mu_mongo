// Creates keys like:
//   [ 'club-hearts', '2005-10-10 03:05:24' ]
//

function(doc) {
	if (doc.data_model == 'News' && doc.club_id) {
		if (doc.published_at)
			emit( [doc.club_id, doc.published_at], 1 );
		else
			emit( [doc.club_id, doc.created_at], 1 );
	};
};
