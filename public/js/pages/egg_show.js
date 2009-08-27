// Safari does not give you access to the datastore during unload events so save them
//  every 5 seconds.

var main_loop_id  = 0;

$(document).ready(function() {
  
  //
  // Show content and hide loading message.
  //
  $('#loading').hide();
  $('#content').show();
  
  
  //
  // Set up callbacks for EggClock
  //
//  var show_work_ele = function(){ $('work').set('styles', {display : 'block', visibility : 'visible' })};
//  EggClock.before_start.push(  Chicken.lay_all_eggs,  show_work_ele );
//  EggClock.after_end.push(   Chicken.window_unload     );
 // EggClock.after_next_second.push(   Chicken.see_if_any_hatched   );
  
//  EggClock.before_test_buzzer.push( function(){ $('instructions').addClass('testing_buzzer'); } );
//  EggClock.after_test_buzzer.push( function(){  $('instructions').removeClass('testing_buzzer');  });
  
  //
  // Start the clock.
  //
  main_loop_id = setInterval( function(){
    BigClock.next_second();
    EggClock.next_second();
  }, 1000 );
  
  //
  // Attach unload events.
  //
  $(document).unload( function() { 
      clearInterval( main_loop_id  ); 
  } );
  
}); // === $(document).ready






// =====================================================
//              Set-up SoundManager 2
// =====================================================
soundManager.url = "/js/vendor/soundmanager2/swf/";


if( window.location.hostname == 'localhost' ) {
  soundManager.debugMode = true;
} else {
  soundManager.debugMode = false;
};

soundManager.onload = function() {
  // SM2 is ready to go!
  var mySound = soundManager.createSound({
    id: 'the_beeps',
    url: 'http://megauni.s3.amazonaws.com/beeping.mp3',
    volume: 90, 
    onfinish: function() {  this.play();      }
  });  
};

soundManager.onerror = function() {
  // SM2 could not start, no sound support, something broke etc. Handle gracefully.
  alert('Something went wrong. Try reloading the page once or twice.'); // for example
}



var BigClock = {
  
  month_names : ['Jan.', 'Feb.', 'Mar.', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'],
  day_names   : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  
  chop_off_milliseconds : function(orig_epoch_time){
                            return( parseInt(orig_epoch_time / 1000) * 1000 );
                          },                                  

  format_minutes    : function(date){ return( (date.getMinutes()<10) ? '0'+date.getMinutes() : date.getMinutes() );},
  format_meridian   : function(date){ return( (date.getHours()>12) ? 'P.M.' : 'A.M.'  ); },
  format_year       : function( date ){ 
                          /* based on function: takeYear from:  http://www.quirksmode.org/js/introdate.html#year */
                          var y = date.getYear() % 100;
                          return( y + ( (y < 38) ? 2000 : 1900 ) ); 
  },
  
  format_seconds : function(date){
      return date.getSeconds() + " " + ((date.getSeconds() == 1) ? 'sec.'  :  'secs.' );
    
  },
  
  format_hour : function( date ){ 
    if( date.getHours() < 1 ) 
      return 12;
      
    return (date.getHours() < 13) ? 
                date.getHours() : 
                date.getHours() % 12 ;

  },
  
  format_time : function( date ){
    return BigClock.format_hour(date) + 
            ':' +  BigClock.format_minutes(date) + 
            ' ' + BigClock.format_meridian(date) ;
  },
  
  format_date : function( date ) {
    return BigClock.month_names[date.getMonth()] + 
          ' ' + date.getDate() + 
          ', ' + BigClock.format_year(date);
  },
    
  next_second : function(){
      /*
          div( :id=>'big_clock' ) { 
            p.day "Saturday"
            p.date "Aug. 8, 2009"
            p.time  "3:03 PM" 
            p.seconds "22 seconds"
          }
      */  
      var right_now    = new Date();

      
      $('#big_clock p.seconds').html( BigClock.format_seconds(right_now) );
      $('#big_clock p.time').html(    BigClock.format_time(right_now) );
      $('#big_clock p.day').html(     BigClock.day_names[right_now.getDay()] );
      $('#big_clock p.date').html(    BigClock.format_date(right_now) );
            
        
  } // === update

}; // === BigClock



var EggClock = {

  epoch_units             : { 'days' : (24 * 60 * 60 * 1000), 'hours' : (60 * 60 * 1000), 'minutes' : (60 * 1000), 'seconds' : 1000},  
  storage_bin             : $([]),
  clock_already_started   : false,
  clock_js_id             : 0,
  
  ///////////////////////////////////////////////////////////////////////////////////////////
  
  
  ///////////////////////////////////////////////////////////////////////////////////////////
    
  is_it_zero_seconds      : function(dt) { return(  dt.getSeconds() < 1  ); },
  is_it_exactly_midnight : function(dt) { 
                                          return( dt.getHours() < 1 && dt.getMinutes() < 1 && dt.getSeconds() < 1 ); 
                                        },
                                        
  ///////////////////////////////////////////////////////////////////////////////////////////   
                                          

                                            
  ///////////////////////////////////////////////////////////////////////////////////////////   
                                    
  next_second : function(){
      //
      // Loop through each work and update.
      //
  }, // end next_second



  get_difference_in_units    : function(beginning_epoch, ending_epoch) {

                                              var units = { 'days' : 0, 'hours' : 0 , 'minutes' : 0, 'seconds' : 0 , 't_sign' : '-', 'times_up' : false};
                                              var earliest     = ( beginning_epoch < ending_epoch ) ? beginning_epoch : ending_epoch;
                                              var latest       = ( beginning_epoch < ending_epoch ) ? ending_epoch : beginning_epoch;
                                              units['t_sign']      = ( beginning_epoch <= ending_epoch ) ? '-' : '';
                                              units['times_up']   = ( ending_epoch <= beginning_epoch );
                                              
                                              var difference = latest - earliest;

                                              // days
                                                units['days'] = parseInt( difference / this.epoch_units['days']  ) ;
                                              // hours
                                                difference =  difference - ( this.epoch_units['days'] * units['days'] );
                                                units['hours'] =  parseInt( difference / this.epoch_units['hours'] ) ;
                                              // minutes 
                                                difference = difference - ( this.epoch_units['hours'] * units['hours']);
                                                units['minutes'] = parseInt( difference / this.epoch_units['minutes'] );
                                              // seconds
                                                difference = difference - ( this.epoch_units['minutes'] * units['minutes'] );
                                                units['seconds'] = Math.ceil( difference / this.epoch_units['seconds'] );

                                              units['invalid'] = !( $chk(units['days']) && $chk(units['hours']) && $chk(units['minutes']) && $chk(units['seconds']) );

                                              return units;

                                              },

  start_buzzer : function(event_id){
                          this.storage_bin.include(event_id);
                          
                          // Stop the 'test' buzzer since we no longer need it.
                          if(event_id != 'test')
                            EggClock.stop_buzzer('test');
                          
                          soundManager.play('the_beeps');
                          return $('alarm_holder');
                    },
  stop_buzzer : function(event_id){
  
                            if(this.storage_bin.length < 1)
                              return false;
                              
                            if(event_id !='test' && this.storage_bin.length ==1 && this.storage_bin[0]=='test' )
                              return false;
                              
                            if(event_id=='test')
                              Swiss.call_these_funcs( this.after_test_buzzer);

                            this.storage_bin.erase(event_id);
                            this.storage_bin.erase('test');

                            
                            if(this.storage_bin.length < 1  )
                              soundManager.stop('the_beeps'); // $('alarm_holder').set( 'html', '');
                              
                            return true;
                          }

}; // end EggClock
