
/** 
 * @author rphillips
 * SCE.SearchComposer accepts min_lat, max_lat, min_lng, max_lng, and search_terms.
 * SCE.SearchComposer provides url strings in SCE URL format
 * (http://url_base/controller/action)/searchTerm1_searchTerm2/min_lat/max_lat/min_lng/max_lng(.format)
 * where lat-lng numbers are formatted with "_" for decimal point.
 */
if (SCE == undefined) 
    var SCE = {};

SCE.SearchComposer = {};


/////////////////
//initialize some constants
////////////////

SCE.SearchComposer.Initialize = function(base_url, gcs_corners, termstring, callback){
    SCE.SearchComposer.base_url = base_url
    SCE.SearchComposer.min_corner = {
        lat: gcs_corners.min_lat,
        lng: gcs_corners.min_lng
    }
    SCE.SearchComposer.max_corner = {
        lat: gcs_corners.max_lat,
        lng: gcs_corners.max_lng
    }
    SCE.SearchComposer.has_box = gcs_corners.has_box
    
    SCE.SearchComposer.updateTerms(termstring)
    SCE.SearchComposer.Options = {};
    function defaults(){
        return null;
    }
    return this;
}


SCE.SearchComposer.updateCorners = function(report){
    SCE.SearchComposer.min_corner.lat = report.min_lat.toFixed(3);
    SCE.SearchComposer.min_corner.lng = report.min_lng.toFixed(3);
    SCE.SearchComposer.max_corner.lat = report.max_lat.toFixed(3);
    SCE.SearchComposer.max_corner.lng = report.max_lng.toFixed(3);
    SCE.SearchComposer.has_box = report.has_box
}


SCE.SearchComposer.updateTerms = function(termstring){
    SCE.SearchComposer.terms = '_'
    if (termstring != '') {
        re = /[^a-z0-9\-]/g
        addend = termstring.toLowerCase();
        addend = addend.replace(re, '_')
        re = /(_)_*/g
        addend = addend.replace(re, '_')
        SCE.SearchComposer.terms = addend
    };
    return SCE.SearchComposer.terms
}

SCE.SearchComposer.readURL = function(){
    var minlatterm = '_';
    var minlngterm = '_';
    var maxlatterm = '_';
    var maxlngterm = '_';
    if (SCE.SearchComposer.has_box) {
        minlatterm = SCE.SearchComposer.min_corner.lat.toString().replace(/\./g, '_');
        maxlatterm = SCE.SearchComposer.max_corner.lat.toString().replace(/\./g, '_');
        minlngterm = SCE.SearchComposer.min_corner.lng.toString().replace(/\./g, '_');
        maxlngterm = SCE.SearchComposer.max_corner.lng.toString().replace(/\./g, '_');
    }
    //var newurl = base_url + destination 
    newurl = ''
    newurl += SCE.SearchComposer.terms + '\/' + minlatterm + '\/' + maxlatterm + '\/' + minlngterm + '\/' + maxlngterm + '\/'
    return newurl
};

