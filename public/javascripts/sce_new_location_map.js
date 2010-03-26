
/**
 * @author rphillips
 * SCE.NewLocationMap comprises a google map and a form and exhibits these traits:
 *    -- it creates an origin marker
 *    -- it creates a draggable current_location marker
 *    -- when the form is submitted, the address text is geocoded and:
 *      -- a reference marker is put on the address
 *      -- the current_location marker is put on top of it
 *    -- whenever the current location marker is changed (by dragging or by finding an address,)
 *       a callback fires to update the lat and lng on the form on the originating page.
 *
 *
 */

//TODO: the callback should fire whenever the current_location_marker is created or dragends.
//TODO: make a query function to return current lat; current lng.

if (SCE == undefined) 
    var SCE = {};

SCE.NewLocationMap = {};
SCE.GeoCoder = {};


/////////////////////////////////////////////////////////////////////////////
// SCE.NewLocationMap.MapObject is the namespace for the main map. ////////////////
/////////////////////////////////////////////////////////////////////////////
SCE.NewLocationMap.MapObject = {};
SCE.NewLocationMap.MapObject.Initialize = function(base_url, id, options, callback){
    SCE.NewLocationMap.base_url = base_url;
    if (GBrowserIsCompatible()) {
        SCE.NewLocationMap.MapObject = new GMap2(document.getElementById(id));
        SCE.NewLocationMap.Geocoder = new GClientGeocoder();
    }
    SCE.NewLocationMap.MapObject.Options = {};
    function defaults(){
        return {
            cy_min_lat: 40.9,
            cy_max_lat: 41.36,
            cy_min_lng: -81.69,
            cy_max_lng: -81.385,
            origin_lat: 41.36 / 2 + 40.9 / 2,
            origin_lng: -81.385 / 2 + -81.69 / 2
        };
    }
    options = jQuery.extend(defaults(), options);
    SCE.NewLocationMap.MapObject.Options = options;
	/////////////////
	//initialize some variables
	////////////////
    var map = SCE.NewLocationMap.MapObject;
	SCE.NewLocationMap.origin_glatlng = new GLatLng(map.Options.origin_lat,map.Options.origin_lng)
	SCE.NewLocationMap.Callback = callback;
	/*////////////////////////////////////////////////////////
 	// SCIcons are the icons used in this map.
 	///////////////////////////////////////////////////////////*/
	SCE.NewLocationMap.Icons = {};
	SCE.NewLocationMap.Icons.bare = new GIcon(G_DEFAULT_ICON);
	SCE.NewLocationMap.Icons.bare.shadow = '';
	SCE.NewLocationMap.Icons.bare.iconSize = new GSize(12,12);
	SCE.NewLocationMap.Icons.bare.iconAnchor = new GPoint(0, 0);
	SCE.NewLocationMap.Icons.bare.infoWindowAnchor = new GPoint(0, 0);

	SCE.NewLocationMap.Icons.reference = new GIcon(SCE.NewLocationMap.Icons.bare);
	SCE.NewLocationMap.Icons.reference.image = SCE.NewLocationMap.base_url + "/images/redball.png";
	SCE.NewLocationMap.Icons.origin = new GIcon(SCE.NewLocationMap.Icons.bare);
	SCE.NewLocationMap.Icons.origin.image = SCE.NewLocationMap.base_url + "/images/blueball.png";
	SCE.NewLocationMap.Icons.location = new GIcon(SCE.NewLocationMap.Icons.bare);
	SCE.NewLocationMap.Icons.location.image = SCE.NewLocationMap.base_url + "/images/white_cross.png";

	map.setCenter(SCE.NewLocationMap.origin_glatlng, 12);
	map.addControl(new GSmallMapControl());
	map.addControl(new GMapTypeControl());
	map.addControl( new GScaleControl());
	// make the origin marker and set the current_location marker on the origin
	SCE.NewLocationMap.origin_location_marker = new GMarker(SCE.NewLocationMap.origin_glatlng, SCE.NewLocationMap.Icons.origin)
	map.addOverlay(SCE.NewLocationMap.origin_location_marker)
	//Keep the position marked with this.
	SCE.NewLocationMap.current_location_marker = new GMarker(SCE.NewLocationMap.origin_glatlng, {icon : SCE.NewLocationMap.Icons.location , draggable : true}) ;
	GEvent.addListener(SCE.NewLocationMap.current_location_marker, 'dragend', function(){
        SCE.NewLocationMap.Callback();
		return false;
    });
	map.addOverlay(SCE.NewLocationMap.current_location_marker);
	return map;
};

//////////////////////////////////////////////////////////////////
//////SCE.NewLocationMap.AddressForm is the namespace for the form//////
//////////////////////////////////////////////////////////////////

SCE.NewLocationMap.AddressForm = {};
SCE.NewLocationMap.AddressForm.Initialize = function(form_id, text_field, options, callback){
    SCE.NewLocationMap.AddressForm = $(form_id);
	SCE.NewLocationMap.AddressForm.TargetSource = text_field
    SCE.NewLocationMap.AddressForm.Options = {};
    function defaults(){
        return {
			start_address:'538 E. South St., Akron, OH 44311'};
    }
    
    options = jQuery.extend(defaults(), options);
    SCE.NewLocationMap.AddressForm.Options = options;
    $('#' + form_id).bind('submit', function(){
        SCE.NewLocationMap.markAddress();
		return false;
    });
	text_field.value = SCE.NewLocationMap.AddressForm.Options.start_address;
	return SCE.NewLocationMap.AddressForm
};

SCE.NewLocationMap.markAddress = function(){
    var address = SCE.NewLocationMap.AddressForm.TargetSource.value
    //alert(SCE.NewLocationMap.Icons[icon_purpose].image);
    if (SCE.NewLocationMap.Geocoder) {
        SCE.NewLocationMap.Geocoder.getLatLng(address, function(point){
            if (!point) {
                alert(address + " not found");
            }
            else {	
				var map = 	SCE.NewLocationMap.MapObject;
				
				map.setCenter(point, 14);
                var marker = new GMarker(point, SCE.NewLocationMap.Icons.reference);
                GEvent.addListener(marker, "click", function(){
                    marker.openInfoWindowHtml(address);
                });
                map.addOverlay(marker);
                marker.openInfoWindowHtml(address);
				SCE.NewLocationMap.setCurrentLatLng(point);
            };
        });
    }
    return false;
};
SCE.NewLocationMap.current_lat = function(){
	return SCE.NewLocationMap.current_location_marker.getLatLng().lat();
};
SCE.NewLocationMap.current_lng = function(){
	return SCE.NewLocationMap.current_location_marker.getLatLng().lng();
};
SCE.NewLocationMap.setCurrentLatLng = function(point){
	
	var map = 	SCE.NewLocationMap.MapObject;
	//var point = new GLatLng(lat, lng);
	//Can't just use .setLatLng, because the current_location_marker overlay must end up on top.
	map.removeOverlay(SCE.NewLocationMap.current_location_marker);
	SCE.NewLocationMap.current_location_marker.setLatLng(point);	
	map.addOverlay(SCE.NewLocationMap.current_location_marker);


	SCE.NewLocationMap.Callback()
	return false;
};
