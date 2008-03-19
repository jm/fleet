= Fleet - The super slim, microwebframework of doom!

Fleet is a very small web framework based on the original idea of Merb: Mongrel serving up
ERb (Embedded Ruby) templates.  The idea has been expanded and now Fleet helps you serve up
ERb, HAML, Textile, Markdown, and Markaby templates.

== Basic Usage

To use Fleet, you have two options.  You can use it in standard mode or application mode. In
standard mode, there is no configuration and Fleet will serve up templates and static files 
from the current folder.  To get this mode, then simply type <tt>fleet start</tt> in any folder.

  $ fleet start
  - fleet version 0.0.1
	   starting server on port 5000

Now navigating to a URL will look in the current folder for the file or template.  For example, going
to <tt>http://localhost:5000/my_template</tt> will look for <tt>my_template.erb</tt> (or whatever template 
engine you are using) in the current folder and render it if available.  If a static file is requested, then
it is served up.  If you request <tt>http://localhost:5000/my_folder/my_template</tt>, then the application
will look in <tt>my_folder</tt> for the <tt>my_template</tt> template.

=== Fleet as an application server

Fleet can also be configured to be used as an application server.  To do so, you can either generate an
application or hand create a <tt>configuration.yml</tt> file (see one from a generated project for an example).
To generate an application, simple run +fleet+ with a project name as the argument.

  fleet my_project
  
This command will generate a number of files.  Chief among these is <tt>configuration.yml</tt> which tells
Fleet how you'd like to run it.  Other files include a sample template and the proper folder structure
for the generated configuration to work properly.  This setup allows you to more easily segment your code
for easier maintenance.

== Helpers

Fleet comes with a few helpers that live in Fleet::Helpers.  You can add your own helpers by creating a
<tt>helpers</tt> folder and stashing modules in there.  As of right now, helpers must live in the Fleet::Helpers
module, but this will hopefully be changing very soon.