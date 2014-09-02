#poodle

## The poodles core
...

## Installation

For developing with Poodle you need nodeJs. Please refer to their homepage for OS-specific installers.

All commands have to be executed in the root of your project.

#### 1. install nodeJS
Refer to their homepage for a OS-specific installer for your system.

#### 2. initialize Grunt

** Note: **
Grunt will install all tools needed for development - runtime dependencies of your website or app will be handled by bower (see below).

Run in the root directory of your workspace:

* `(sudo) npm install -g grunt-cli` 
* `(sudo) npm install -g bower` 
* `(sudo) npm install` 

sudo might be needed on some systems like OSX. This will download and setup the development listed in your `package.json` file. As a result you'll get a folder 'node_modules' being created.

Note: 
watch your console for errors during `npm install` to ensure you get a working installation. Sometimes administrator rights are needed for a correct install.


#### 3. initialize Bower

Bower manages the components your website or app uses.

Run: 

`bower install`

This will download the dependencies listed in bower.json - typically the components your website is made of like bootstrap and jquery. After completion you'll find a folder named 'components' in the root of your app.

NOTE: if for some reason your grunt tasks are not working as expected it sometimes helps to completely re-install all libs listed in package.json. For this delete your 'node_modules' directory and run `npm install` again.


## Grunt command reference

Call these commnands in the root dir of your application:

`grunt [task]`

Task | Description |
-------- | ----------------
`default` | default Grunt task will create a .xar file in directory `build` containing the full source of the components managed by bower
`dist`| creates a fully-optimized version of the .xar application

If you are seeking detail information about the single targets please refer to `gruntfile.js` for inline documentation.

## Customization

### Optimizing JavaScript

** Important **:

You should review the 'concat` task in `gruntfile.js` to make sure all of your JavaScript dependencies get concatenated. 

### animate.css

Offers a large set of premade CSS animations. As you'll use only a small subset of these you should adapt the file `components/animate.css/animate-config.json` and set unused animations to false e.g.:

`"flip": false,`

** Important **:
animate.css uses its own mechanism for optimization which can be triggered by a watch task (still to do) or by adapting the grunt tasks from original animate.css.


#### Some things to watch

** ! special caution is needed when using eXide with synchronization on - you might break pages (which got processed by grunt previously) when working live with an optimized version. Advice: don't do it. Production versions should only the used for testing - not fixing ! **

** animate.css ** has its own optimization through Grunt. You should always run

`grunt watch`in directory `components/animate.css` and modify and store the file `.animate-config.json` to trigger optimization manually.


Afterwards create an optimized version of the whole app by running:

`grunt`

in the root of the application (this directory).

You should consult the `gruntfile.js` for details.

#### Attention with dynamically generated CSS classes

The grunt build tool uses `uncss`- a tool to discover and remove unused CSS classes from the resulting CSS. However this statically analyses one or more html pages. When JS routines dynamically add classes to the DOM at runtime these cannot be detected by `uncss`. Such classes can be held in a separate css file for instance.

Dynamic behavior should always be tested after optimization.
