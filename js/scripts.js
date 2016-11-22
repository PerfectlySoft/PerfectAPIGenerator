/*!
* A.mphibio.us  1.5.2
* Copyright 2014, @cliveMoore @Treefrog
* http://a.mphibio.us
* Free to use under the MIT license.
* http://www.opensource.org/licenses/mit-license.php
* 21/11/2014
*
*/

/* ==================================================================
 * amp object is the foundation namespaced A.mphibio.us JS
 * Do not remove or comment out.
 * ================================================================== */
var amp = {};

/* ==================================================================
 * amp.init is run on DOM ready
 * Do not remove or comment out.
 * ================================================================== */
amp.init = function() {
	/* ==================================================================
		* cache: uncomment if you wish to enable and add content caching only.
		* ================================================================== */
	// amp.cache();

	/* ==================================================================
		* amp.bindlisteners() is an essential function. Do not remove or comment out.
		* ================================================================== */
	amp.bindlisteners();

	/* ==================================================================
		* Discern mobile or desktop and init specific behaviour for each.
		* ================================================================== */
	if (!Modernizr.touch) {
		amp.desktoplisteners();
	} else {
		amp.mobilelisteners();
	}

};

amp.cache = function() {
	/* ==================================================================
		* Add content caching here
		* ================================================================== */
	amp.dom = {};
};

amp.bindlisteners = function() {
	/* ==================================================================
		* Bind Listeners
		* These are bound once the scripts, css and DOM are fully loaded
		* ================================================================== */

	/* General layout helpers */
	$('table td:first-child').addClass('first');
	$('table tr:nth-child(2n+1)').addClass('odd');
	$('table tr:nth-child(2n)').addClass('even');
	$('table tr:first-child').addClass('first');
	$('table tr:last-child').addClass('last');
	$('table td:first-child').addClass('first');
	$('table td:last-child').addClass('last');
	$('table th:first-child').addClass('first');
	$('table th:last-child').addClass('last');
	$('ul li:first-child').addClass('first');
	$('ul li:last-child').addClass('last');


	$(document).on('click', '.checkall', (function () {
		$(this).closest('fieldset').find(':checkbox').prop('checked', this.checked);
	}));

	$(document).on('click', '#nav li', (function(){
		if ($(this).hasClass('active')) {
		} else {
			$('#nav li').removeClass('active');
			$(this).addClass('active');
			/* I May use this later
			$(content).show().addClass('active').siblings().hide().removeClass('active'); */
		}
	}));

	$(document).on( 'click', '.tabs li a', (function(){
		var parent = $(this).closest('ul').attr('id');
		var content = '#'+$(this).attr('amp-tab-content');
		if ($(this).hasClass('active') && content.length) {
		} else {
			if (parent > 0)
			{
				$('#'+parent+'.tabs li a').removeClass('active');
				$(this).addClass('active');
			} else {
				$('.tabs li a').removeClass('active');
				$(this).addClass('active');
			}
			$(content).show().addClass('active').siblings().hide().removeClass('active');
		}
		return false;
	}));

	$(document).on('change', '.options_select', (function(){
		
		var target = '.options_div.' + $(this).val();
		
		$('.options_div').each(function(){
			$(this).addClass('hide');
		});
		console.log(target);
		if( $(target).length > 0 ){
			$(target).removeClass('hide');
		}
	}));


	$(document).on( 'click', '.opener', (function(){
		
		var thisOfCourse = $(this).attr('amp-target');
		
		if($('#'+$(this).attr('amp-target')).hasClass('hide')){
			$('#'+thisOfCourse+'').removeClass('hide');
		} else {
			$('#'+thisOfCourse+'').addClass('hide');
		}
	}));
	
	$(document).on( 'click', '.amp_trigger', (function(){
		
		var myLocal = $(this).attr('location');
		
		if($(this).attr('clicktype') == 'out') {
			window.open($(this).attr('location'));
		} else {
			document.location.href = $(this).attr('location');
		}
	}));

	$(document).on( 'click', '.modal_opener', (function(){
		
		var thisOfCourse = $(this).attr('amp-target');
		
		if($('#'+$(this).attr('amp-target')).hasClass('show')){
			$('body').css('overflow','auto');
			$('#'+thisOfCourse+'').removeClass('show');
			$('.focus').removeClass('blur');
		} else {
			$('body').css('overflow','hidden');
			$('#'+thisOfCourse+'').addClass('show').css('overflow','auto');
			$('.focus').addClass('blur');

			var content = '#'+$(this).attr('amp-tab-content');
			var contenttabheader = '#trigger_'+$(this).attr('amp-tab-content');
			
			if ($(contenttabheader).hasClass('active') && content.length) {
			} else {
				$('.tabs li a').removeClass('active');
				$(contenttabheader).addClass('active');
				$(content).show().addClass('active').siblings().hide().removeClass('active');
			}

		}
	}));

	$(document).on( 'click', '.modal_kill', (function(){
		var killIt = $(this).attr('amp-target');
			$('body').css('overflow','auto');
			$('#'+killIt+'').removeClass('show');
			$('.focus').removeClass('blur');
	}));

	$(document).on( 'click', '#main-call-to-actions ul.buttons li:nth-child(4)', (function(){
		$(this).toggleClass('animated');
		
	}));
	
	$(document).on( 'click', '#navtoggle', (function(){
		if($('#navtoggle').hasClass('active')){
			$('#navtoggle').removeClass('active');
			$('#mainnav').removeClass('open animated bounceIn');
		} else {
			$('#navtoggle').addClass('active');
			$('#mainnav').addClass('open animated bounceIn');
		}
	}));
	
	$(document).on( 'click', '#search_toggle', '#search_cancel', (function(){
		if($('#search_toggle').hasClass('active')){
			$('#search_toggle').removeClass('active');
			$('#search_toggle .icon-search').removeClass('hide');
			$('#search_toggle .icon-cross').addClass('hide');
			$('#search_form').removeClass('open');
		} else {
			$('#search_toggle').addClass('active');
			$('#search_toggle .icon-cross').removeClass('hide');
			$('#search_toggle .icon-search').addClass('hide');
			$('#search_form').addClass('open');
		}
	}));
	

};

amp.mobilelisteners = function() {
	/* ==================================================================
		* Mobile browser specific listeners are placed here
		* *** NOT *** executed by desktop browsers. See amp.desktoplisteners instead.
		* ================================================================== */
		
$(document).on('click', '.touch .mainmenu li a.okgo', function(){
        window.location.href = $(this).attr('href');
    });

    $(document).on('click', '.touch .mainmenu a.submenu', function(e){
        e.preventDefault();
        var grandparent = $(this).parent().parent().attr('class');

        //if another root item...
        if(grandparent == 'mainmenu'){
            //remove extraneous okgo classes and apply to only current root item
            $('.okgo').removeClass('okgo');
            $(this).addClass('okgo');
            //hide other menu items
            $('ul.display').removeClass('display');
        } else {
            $(this).addClass('okgo');
        }
        
        $(this).siblings('ul').addClass('display');
    });
};

amp.desktoplisteners = function() {
	/* ==================================================================
		* Desktop browser specific listeners are placed here
		* *** NOT *** executed by mobile browsers. See amp.mobilelisteners instead.
		* ================================================================== */

	initTabNav();

};

$(document).ready(function() {
	/* ==================================================================
		* The document.ready is executed once all scripts and CSS are loaded
		* and the DOM has been readied.
		* Generally is used to bind listeners for responsive web
		* Generally a good thing to add listeners to the object,
		* however it is ok to be putting listeners directly in here.
		* ================================================================== */
	amp.init(); // don't delete this - it is part of the A.mphibio.us startup

	$('ul#nav').children('li').clone().prependTo('ul#mobilenav');
	
	$('.animate').removeClass('animated');
	
	/* Load News & Events HTML Files */
	$('#news-feed').load('news-feed.html');
	$('#event-feed').load('event-feed.html');
	$('#sponsorship').load('our-sponsorship.html');
	$('#blog-subnav').load('blog-subnav.html');

	
});


// Tab key handling for accessible submenu navigation
// Plugin adds .hover class to link parent li's when "tab-focused"
// Remember to add li.hover > ul { style rules } in css file
function initTabNav() {
	jQuery('ul#nav').tabNav({
		items: 'li'
	});
}
