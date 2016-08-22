//ANIMATED EFFECTS MIGRATED FROM: http://daneden.me/animate/
//THESE EFFECTS ARE ACTIVATED VIA WAYPOINT FUNCTION
//Please see documentation for more info about the usage


$(document).ready(function(){
      $('.page-section').waypoint(function (event, direction) {
	        console.log('waypoint');
        if (direction === 'down') {
	        console.log('down');
            $(this).find('.fx-flash').addClass('animated flash');
            $(this).find('.fx-bounce').addClass('animated bounce');
            $(this).find('.fx-shake').addClass('animated shake');
            $(this).find('.fx-tada').addClass('animated tada');
            $(this).find('.fx-swing').addClass('animated swing');
            $(this).find('.fx-wobble').addClass('animated wobble');
            $(this).find('.fx-wiggle').addClass('animated wiggle');
            $(this).find('.fx-pulse').addClass('animated pulse');
            $(this).find('.fx-fadeInDownBig').addClass('animated fadeInDownBig');
            $(this).find('.fx-fadeInUpBig').addClass('animated fadeInUpBig');
            $(this).find('.fx-fadeInLeftBig').addClass('animated fadeInLeftBig');
            $(this).find('.fx-fadeInRightBig').addClass('animated fadeInRightBig');
            $(this).find('.fx-fadeInDown').addClass('animated fadeInDown');
            $(this).find('.fx-fadeInUp').addClass('animated fadeInUp');
            $(this).find('.fx-fadeInLeft').addClass('animated fadeInLeft');
            $(this).find('.fx-fadeInRight').addClass('animated fadeInRight');  
            $(this).find('.fx-fadeOutDownBig').addClass('animated fadeOutDownBig');
            $(this).find('.fx-fadeOutUpBig').addClass('animated fadeOutUpBig');
            $(this).find('.fx-fadeOutLeftBig').addClass('animated fadeOutLeftBig');
            $(this).find('.fx-fadeOutRightBig').addClass('animated fadeOutRightBig');
            $(this).find('.fx-fadeOutDown').addClass('animated fadeOutDown');
            $(this).find('.fx-fadeOutUp').addClass('animated fadeOutUp');
            $(this).find('.fx-fadeOutLeft').addClass('animated fadeOutLeft');
            $(this).find('.fx-fadeOutRight').addClass('animated fadeOutRight');
            $(this).find('.fx-bounceIn').addClass('animated bounceIn');
            $(this).find('.fx-bounceOut').addClass('animated bounceOut');
            $(this).find('.fx-bounceInUp').addClass('animated bounceInUp');
            $(this).find('.fx-bounceInDown').addClass('animated bounceInDown');
            $(this).find('.fx-bounceInLeft').addClass('animated bounceInLeft');
            $(this).find('.fx-bounceInRight').addClass('animated bounceInRight');
            $(this).find('.fx-bounceOutUp').addClass('animated bounceOutUp');
            $(this).find('.fx-bounceOutDown').addClass('animated bounceOutDown');
            $(this).find('.fx-bounceOutLeft').addClass('animated bounceOutLeft');
            $(this).find('.fx-bounceOutRight').addClass('animated bounceOutRight');
            $(this).find('.fx-rotateIn').addClass('animated rotateIn');
            $(this).find('.fx-rotateInDownLeft').addClass('animated rotateInDownLeft');
            $(this).find('.fx-rotateInDownRight').addClass('animated rotateInDownRight');
            $(this).find('.fx-rotateInUpLeft').addClass('animated rotateInUpLeft');
            $(this).find('.fx-rotateInUpRight').addClass('animated rotateInUpRight');
            $(this).find('.fx-rotateOut').addClass('animated rotateOut');
            $(this).find('.fx-rotateOutDownLeft').addClass('animated rotateOutDownLeft');
            $(this).find('.fx-rotateOutDownRight').addClass('animated rotateOutDownRight');
            $(this).find('.fx-rotateOutUpLeft').addClass('animated rotateOutUpLeft');
            $(this).find('.fx-rotateOutUpRight').addClass('animated rotateOutUpRight');
            $(this).find('.fx-lightSpeedIn').addClass('animated lightSpeedIn');
            $(this).find('.fx-lightSpeedOut').addClass('animated lightSpeedOut');
            $(this).find('.fx-hinge').addClass('animated hinge');
            $(this).find('.fx-rollOut').addClass('animated rollOut');
            $(this).find('.fx-rollIn').addClass('animated rollIn');
            $(this).find('.fx-rollOut').addClass('animated rollOut');
        } else {
	         console.log('up');
        }
    }, { offset: 100 });

})