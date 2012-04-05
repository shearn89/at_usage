 $(function(){
   var path = location.pathname.substring(1);
   if ( path ) {
		 var parent = $('.nav a[href$="' + path + '"]').parent()
	     parent.attr('class', 'active');
		 if (parent.parent().attr('class') == 'dropdown-menu') {
			 parent.parent().parent().attr('class', 'dropdown active');
		 }
		 if (path == 'machines') {
			 $('.nav a[href$="/"]').parent().attr('class', 'active');
		 }
   } else {
		 $('.nav a[href$="/"]').parent().attr('class', 'active');
	 }
 });