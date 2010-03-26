ScaffoldService

Scaffolding, out of the box, is terrible for an artsy-fartsy site. However, 
if you are working with legacy data, and just need to put a browser front-end on it, it saves a ton 
of time.

This plugin takes code from Rails' legacy scaffold generator and makes it available again, 
but now it works with the REST oriented framework. 

This generator is mainly oriented toward publishing the contents of the table in various 
formats (index and show actions, only). The pages are ugly, but they work. 
The other generator of the pair, ScaffoldReflect, is the full-boat CRUD with all the pages written..


== FEATURES/PROBLEMS:
  

== SYNOPSIS:

Typically, ScaffoldService will not be used in the Admin part of the site. Its purpose is to do index and show 
actions, so just:

  ruby script/generate scaffold_service Project

== REQUIREMENTS:

* Rails, a model, and a table in your database that is already migrated.

== INSTALL:

Copy the files into lib/generators/


== LICENSE:

(The MIT License)

Copyright (c) 2008 Ron Phillips with code from http://dev.rubyonrails.org/ via 
Brian Hogan's ScaffoldForm generator.


Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
