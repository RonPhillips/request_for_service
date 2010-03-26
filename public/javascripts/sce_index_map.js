/**
 * @author rphillips
 * SCE.IndexMap accepts a google map and an html table and exhibits these traits:
 *    -- it accepts SCEPoints (lat, lon, label, http://address, detailsObject)
 *    -- it creates markers on the map for all the SCEPoints
 *    -- it endows the markers with two behaviors:
 *      -- single-click changes the color and size of the marker, and the corresponding row in the table
 *      -- double-click displays an InfoBox on the map, with details and/or links to a detail page
 *    -- it fills the html table with the marker number, a link built from label and http, and details
 *       from the detailsObject
 *    -- it endows the html table rows with a behavior whereby clicking the row changes its color
 *       and single-clicks the corresponding marker, TODO:double-clicking the row double-clicks
 *       the corresponding marker
 */
if (SCE == undefined)
    var SCE = {};

SCE.IndexMap = {};

/////////////////
//initialize some variables
////////////////

/////////////////////////////////////////////////////////
// SCIcons are the icons used in this map.
////////////////////////////////////////////////////////////

SCE.IndexMap.Icons = {};

/////////////////////////////////////////////////////////////////////////////
// SCE.IndexMap.MapObject is the namespace for the main map. ////////////////
/////////////////////////////////////////////////////////////////////////////
SCE.IndexMap.MapObject = {};
SCE.IndexMap.MapObject.Initialize = function(base_url, id, options, callback) {
    SCE.IndexMap.base_url = base_url;
    SCE.IndexMap.MapObject.Options = {};
    function defaults() {
        return {
            cy_min_lat: 40.9,
            cy_max_lat: 41.36,
            cy_min_lng: -81.69,
            cy_max_lng: -81.385
        };
    }

    options = jQuery.extend(defaults(), options);
    SCE.IndexMap.MapObject.Options = options;
    SCE.IndexMap.lomarkers = [];//blue
    SCE.IndexMap.himarkers = [];//red
    
    SCE.IndexMap.MapObject = new google.maps.Map(document.getElementById(id),options);
    return SCE.IndexMap;
   
};
//this creates a lo and hi vis marker, adds them to their array, paints the screen, and hides the himarker
SCE.IndexMap.infowindow = new google.maps.InfoWindow();
SCE.IndexMap.createMarkers = function(line_number, lat, lng, saying) {
    var src = SCE.IndexMap.base_url + '/images/number_GIcon/iconb' + line_number + '.png';
    var pt = new google.maps.LatLng(lat, lng);
    //make the lomarker and add it to lomarkers
	lomarker_options = {position: pt, map: SCE.IndexMap.MapObject, title: saying, clickable: true, icon: src}
    var lomarker = new google.maps.Marker(lomarker_options);
    google.maps.event.addListener(lomarker, "click", function() {
        SCE.IndexMap.toggleVis(line_number);
    });
    google.maps.event.addListener(lomarker, 'dblclick', function() {
        SCE.IndexMap.toggleVis(line_number);
        SCE.IndexMap.infowindow.setContent('<p>'+saying+'</p>');
		SCE.IndexMap.infowindow.open(SCE.IndexMap.MapObject, lomarker)
    });
    SCE.IndexMap.lomarkers[line_number] = lomarker;
    //paint the lomarker on the map
    //SCE.IndexMap.MapObject.addOverlay(SCE.IndexMap.lomarkers[line_number]);

    //make the himarker and add it to himarkers
    src = SCE.IndexMap.base_url + '/images/number_GIcon/marker' + line_number + '.png';
	himarker_options = {position: pt, map:SCE.IndexMap.MapObject, title: saying, clickable:true, visible:false, icon:src}
    var himarker = new google.maps.Marker(himarker_options);
    google.maps.event.addListener(himarker, "click", function() {
        SCE.IndexMap.toggleVis(line_number);
    });
    google.maps.event.addListener(himarker, 'dblclick', function() {
        SCE.IndexMap.toggleVis(line_number);
        SCE.IndexMap.infowindow.setContent('<p>'+saying+'</p>');
		SCE.IndexMap.infowindow.open(SCE.IndexMap.MapObject, himarker)

    });


    SCE.IndexMap.himarkers[line_number] = himarker;
    //SCE.IndexMap.MapObject.addOverlay(SCE.IndexMap.himarkers[line_number]);
    //$(SCE.IndexMap.himarkers[line_number]).hide();
    return SCE.IndexMap.lomarkers[line_number];
};

SCE.IndexMap.toggleVis = function(i) {
    var mo = SCE.IndexMap;
    if (mo.lomarkers[i]) {
        if (mo.lomarkers[i].getVisible()) {
			//alert(mo.lomarkers[i].getVisible())
            mo.himarkers[i].setVisible(true);
            mo.lomarkers[i].setVisible(false);
            $('#result_table_row_' + i).addClass('highlighted');

        }
        else {
            mo.lomarkers[i].setVisible(true);
            mo.himarkers[i].setVisible(false);
            $('#result_table_row_' + i).removeClass('highlighted');
        }
    }
};
//////////////////////////////////////////////////////////////////
//////SCE.IndexMap.TableObject is the namespace for the table//////
//////////////////////////////////////////////////////////////////

SCE.IndexMap.TableObject = {};
SCE.IndexMap.TableObject.Initialize = function(table_id, options, callback) {
    SCE.IndexMap.TableObject = $(table_id);
    SCE.IndexMap.TableObject.Options = {};
    function defaults() {
        return {
            columns: ['Line', 'Name']
        };
    }

    options = jQuery.extend(defaults(), options);
    SCE.IndexMap.TableObject.Options = options;
    $('#' + table_id + ' tr').bind('click', function() {
        SCE.IndexMap.toggleVis($(this)[0].rowIndex - 1);
    });
    /*
     Someday, I'll get this to work:
     $('#' + table_id + ' tr').bind('dblclick', function(){
     alert($(SCE.IndexMap.lomarkers[($(this)[0].rowIndex - 1)]).is(':hidden'));
     $(SCE.IndexMap.lomarkers[($(this)[0].rowIndex - 1)]).dblclick();
     return false;
     });

     */
};


