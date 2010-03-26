
/**
 * @author rphillips
 * This takes a map as an argument, and installs itself as a search box with controls. It takes a callback
 * function that can be executed. In this case, the callback will run when the corners of the search box are
 * moved.
 */
if (SCE == undefined) 
    var SCE = {};

SCE.SearchBox = {};

SCE.SearchBox.Initialize = function(scmap, options, callback){
    SCE.SearchBox.Options = {};
    SCE.SearchBox.p_gon = null;
    SCE.SearchBox.drag_markers = [];
    SCE.SearchBox.polygon_vertices = [];
    SCE.SearchBox.CallBack = callback;
    
    function defaults(){
        // red marker icon
        var dragicon = new GIcon();
        dragicon.image = "http://labs.google.com/ridefinder/images/mm_20_red.png";
        dragicon.shadow = "http://labs.google.com/ridefinder/images/mm_20_shadow.png";
        dragicon.iconSize = new GSize(12, 20);
        dragicon.shadowSize = new GSize(22, 20);
        dragicon.iconAnchor = new GPoint(6, 20);
        //icon.infoWindowAnchor = new GPoint(5, 1);
        
        return {
            cy_min_lat: 40.9,
            cy_max_lat: 41.36,
            cy_min_lng: -81.69,
            cy_max_lng: -81.385,
            //misc
            drag_icon: dragicon
        }
    }
    opts = jQuery.extend(defaults(), options);
    SCE.SearchBox.Options = opts;
    SCE.SearchBox.min_corner = {'lat':SCE.SearchBox.Options.box_min_lat, 'lng':SCE.SearchBox.Options.box_min_lng}
    SCE.SearchBox.max_corner = {lat:SCE.SearchBox.Options.box_max_lat, lng:SCE.SearchBox.Options.box_max_lng}
    SCE.SearchBox.MapObject = scmap.MapObject;
    SCE.SearchBox.MapObject.addControl(new SCE.ZoomControl());
    //SCE.SearchBox.TurnOn()
    SCE.SearchBox.zoomCounty();
    SCE.SearchBox.CallBack();
    
}

SCE.SearchBox.Draw = function(){
    //This continuously updates the polygon on the map as the drag_markers are moved.
    SCE.SearchBox.polygon_vertices.length = 0;
    SCE.SearchBox.corner_lats = [SCE.SearchBox.drag_markers[0].getLatLng().lat(), SCE.SearchBox.drag_markers[1].getLatLng().lat()].sort(function(a,b){return a - b});
    SCE.SearchBox.corner_lngs = [SCE.SearchBox.drag_markers[0].getLatLng().lng(), SCE.SearchBox.drag_markers[1].getLatLng().lng()].sort(function(a,b){return a - b});
    SCE.SearchBox.min_corner.lat = SCE.SearchBox.corner_lats[0]
    SCE.SearchBox.min_corner.lng = SCE.SearchBox.corner_lngs[0]
    SCE.SearchBox.max_corner.lat = SCE.SearchBox.corner_lats[1]
    SCE.SearchBox.max_corner.lng = SCE.SearchBox.corner_lngs[1]
    SCE.SearchBox.polygon_vertices = [new GLatLng(SCE.SearchBox.min_corner.lat, SCE.SearchBox.min_corner.lng), new GLatLng(SCE.SearchBox.max_corner.lat, SCE.SearchBox.min_corner.lng), new GLatLng(SCE.SearchBox.max_corner.lat, SCE.SearchBox.max_corner.lng), new GLatLng(SCE.SearchBox.min_corner.lat, SCE.SearchBox.max_corner.lng), new GLatLng(SCE.SearchBox.min_corner.lat, SCE.SearchBox.min_corner.lng)]
    if (SCE.SearchBox.p_gon) {
        SCE.SearchBox.MapObject.removeOverlay(SCE.SearchBox.p_gon)
    };
    SCE.SearchBox.p_gon = new GPolygon(SCE.SearchBox.polygon_vertices, '#FF0000', 3, 1, '#057aaf', 0.2);
    SCE.SearchBox.MapObject.addOverlay(SCE.SearchBox.p_gon);
    SCE.SearchBox.p_gon.redraw(true)
    //SCE.SearchBox.Fit()();  // realtime fit
};

SCE.SearchBox.DrawLimits = function(){
    //this puts the box on the map
    SCE.SearchBox.drag_markers[0] = new GMarker(new GLatLng(SCE.SearchBox.min_corner.lat, SCE.SearchBox.min_corner.lng), {
        icon: SCE.SearchBox.Options.drag_icon,
        draggable: true
    });
    SCE.SearchBox.MapObject.addOverlay(SCE.SearchBox.drag_markers[0]);
    SCE.SearchBox.drag_markers[0].enableDragging();
    GEvent.addListener(SCE.SearchBox.drag_markers[0], 'drag', function(){
        SCE.SearchBox.Draw()
    });
    GEvent.addListener(SCE.SearchBox.drag_markers[0], 'dragend', function(){
        SCE.SearchBox.Recolor('green');
        //SCE.SearchBox.Fit()();
        SCE.SearchBox.CallBack();
    });
    SCE.SearchBox.drag_markers[1] = new GMarker(new GLatLng(SCE.SearchBox.max_corner.lat, SCE.SearchBox.max_corner.lng), {
        icon: SCE.SearchBox.Options.drag_icon,
        draggable: true
    });
    SCE.SearchBox.MapObject.addOverlay(SCE.SearchBox.drag_markers[1]);
    SCE.SearchBox.drag_markers[1].enableDragging();
    GEvent.addListener(SCE.SearchBox.drag_markers[1], 'drag', function(){
        SCE.SearchBox.Draw()
    });
    GEvent.addListener(SCE.SearchBox.drag_markers[1], 'dragend', function(){
        SCE.SearchBox.Recolor('green');
        //SCE.SearchBox.Fit()();
        SCE.SearchBox.CallBack();
    });
};

////////change color of the SCE.SearchBox.p_gon
SCE.SearchBox.Recolor = function(rgb){
    if (SCE.SearchBox.p_gon) {
        SCE.SearchBox.p_gon.color = rgb;
        SCE.SearchBox.p_gon.redraw(true);
    }
};

////zoom to fit
SCE.SearchBox.Fit = function(){
    var bounds = new GLatLngBounds();
    var locs = SCE.SearchBox.Report();
    bounds.extend(new GLatLng(locs.min_lat, locs.min_lng))
    bounds.extend(new GLatLng(locs.max_lat, locs.max_lng))
    var center = bounds.getCenter();
    SCE.SearchBox.MapObject.setCenter(center, SCE.SearchBox.MapObject.getBoundsZoomLevel(bounds));
    SCE.SearchBox.CallBack()
};


SCE.SearchBox.Report = function(){
    if (SCE.SearchBox.p_gon) {
        return {
            min_lat: SCE.SearchBox.min_corner.lat,
            max_lat: SCE.SearchBox.max_corner.lat,
            min_lng: SCE.SearchBox.min_corner.lng,
            max_lng: SCE.SearchBox.max_corner.lng,
            has_box: true
        };
    }
    else {
        var opts = SCE.SearchBox.Options
        return {
            min_lat: SCE.SearchBox.Options.cy_min_lat,
            max_lat: SCE.SearchBox.Options.cy_max_lat,
            min_lng: SCE.SearchBox.Options.cy_min_lng,
            max_lng: SCE.SearchBox.Options.cy_max_lng,
            has_box: false
        };
    }
};
SCE.SearchBox.TurnOn = function(){
    if (SCE.SearchBox.p_gon) {
        //do nothing
    }
    else {
        SCE.SearchBox.DrawLimits();
        SCE.SearchBox.Draw();
        SCE.SearchBox.Recolor('green');
    }
}

SCE.SearchBox.TurnOff = function(){
    if (SCE.SearchBox.p_gon) {
        SCE.SearchBox.MapObject.removeOverlay(SCE.SearchBox.p_gon);
        SCE.SearchBox.MapObject.removeOverlay(SCE.SearchBox.drag_markers[0]);
        SCE.SearchBox.MapObject.removeOverlay(SCE.SearchBox.drag_markers[1]);
        SCE.SearchBox.p_gon = null;
    }
}

SCE.SearchBox.zoomCounty = function(){
    var bounds = new GLatLngBounds();
    var opt = SCE.SearchBox.Options
    bounds.extend(new GLatLng(SCE.SearchBox.Options.cy_min_lat, SCE.SearchBox.Options.cy_min_lng))
    bounds.extend(new GLatLng(SCE.SearchBox.Options.cy_max_lat, SCE.SearchBox.Options.cy_max_lng))
    var center = bounds.getCenter();
    SCE.SearchBox.MapObject.setCenter(center, SCE.SearchBox.MapObject.getBoundsZoomLevel(bounds));
}
SCE.SearchBox.get_drag_markers = function(){
    return SCE.SearchBox.drag_markers
}

/////////////////////// 

///////////////////////COUNTY ZOOM CONTROL STUFF //////////////////        
SCE.ZoomControl = function(){
};

SCE.ZoomControl.prototype = new GControl();

// Creates a one DIV for each of the buttons and places them in a container
// DIV which is returned as our control element. We add the control to
// to the map container and return the element for the map class to
// position properly.
SCE.ZoomControl.prototype.initialize = function(map){
    var container = document.createElement("div");
    
    var zoomInDiv = document.createElement("div");
    this.setButtonStyle_(zoomInDiv);
    container.appendChild(zoomInDiv);
    zoomInDiv.appendChild(document.createTextNode("Limits On/Off"));
    GEvent.addDomListener(zoomInDiv, "click", function(){
        if (SCE.SearchBox.p_gon) {
            SCE.SearchBox.TurnOff();
            SCE.SearchBox.CallBack()
        }
        else {
            SCE.SearchBox.TurnOn();
            SCE.SearchBox.CallBack();
        }
    });
    
    var zoomOutDiv = document.createElement("div");
    this.setButtonStyle_(zoomOutDiv);
    container.appendChild(zoomOutDiv);
    zoomOutDiv.appendChild(document.createTextNode("Zoom County"));
    GEvent.addDomListener(zoomOutDiv, "click", function(){
        SCE.SearchBox.zoomCounty();
    });
    
    var fitBoxDiv = document.createElement("div");
    this.setButtonStyle_(fitBoxDiv);
    container.appendChild(fitBoxDiv);
    fitBoxDiv.appendChild(document.createTextNode("Zoom Limits"));
    GEvent.addDomListener(fitBoxDiv, "click", function(){
        if (SCE.SearchBox.p_gon) {
        }
        else {
            SCE.SearchBox.TurnOn();
            SCE.SearchBox.CallBack();
        }
        SCE.SearchBox.Fit();
    });
    
    SCE.SearchBox.MapObject.getContainer().appendChild(container);
    return container;
}

// By default, the control will appear in the top left corner of the
// map with 7 pixels of padding.
SCE.ZoomControl.prototype.getDefaultPosition = function(){
    return new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(7, 120));
};

// Sets the proper CSS for the given button element.
SCE.ZoomControl.prototype.setButtonStyle_ = function(button){
    button.style.textDecoration = "underline";
    button.style.color = "#0000cc";
    button.style.backgroundColor = "white";
    button.style.font = "small Arial";
    button.style.border = "1px solid black";
    button.style.padding = "2px";
    button.style.marginBottom = "3px";
    button.style.textAlign = "center";
    button.style.width = "6em";
    button.style.cursor = "pointer";
};
///////////////////////END COUNTY ZOOM CONTROL STUFF //////////////////           



