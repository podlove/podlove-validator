/*
 *
 * Copyright (c) 2014 eXist Solutions
 * Licensed under the MIT license.
 */

'use strict';

/* jshint indent: 2 */

module.exports = function (grunt) {

    require('load-grunt-tasks')(grunt, {scope: 'devDependencies'});
//    require('time-grunt')(grunt);

    // Actually load this plugin's task(s).
    //grunt.loadTasks('tasks');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-imagemin');
    grunt.loadNpmTasks('grunt-zip');
    grunt.loadNpmTasks('grunt-text-replace');
    grunt.loadNpmTasks('grunt-uncss');
    grunt.loadNpmTasks('grunt-contrib-less');


    // Project configuration.
    grunt.initConfig({
        xar: grunt.file.readJSON('package.json'),

        jshint: {
            all: [
                'gruntfile.js'
            ],
            options: {
                jshintrc: '.jshintrc'
            }
        },

        // Before generating any new files, remove any previously-created files.
        clean: {
            tests: ['build', 'dist']
        },

        /*
         replaces tokens in expath-pkg.tmpl and creates expath-pkg.xml with substituted values
         */
        replace: {
            pkg1: {
                src: ['expath-pkg.tmpl'],
                dest: 'expath-pkg.xml',
                replacements: [
                    {
                        from: '@APPVERSION@',
                        to: '<%= xar.version %>'
                    },
                    {
                        from: '@APPNAME@',
                        to: '<%= xar.name %>'
                    },
                    {
                        from: '@APPDESCRIPTION@',
                        to: '<%= xar.description %>'
                    },
                    {
                        from: '@APPURL@',
                        to: '<%= xar.url %>'
                    }
                ]
            },
            pkg2: {
                src: ['repo.tmpl'],
                dest: 'repo.xml',
                replacements: [
                    {
                        from: '@APPLICENSE@',
                        to: '<%= xar.license %>'
                    },
                    {
                        from: '@APPNAME@',
                        to: '<%= xar.name %>'
                    },
                    {
                        from: '@APPDESCRIPTION@',
                        to: '<%= xar.description %>'
                    },
                    {
                        from: '@APPAUTHOR@',
                        to: '<%= xar.author %>'
                    }
                ]
            }
        },

        /*
        Copy copies all relevant files for building a distribution in 'dist' directory
        */
        // CSS and JS resources are copied as they get processed by their respective optimization tasks later in the chain.
        // png images will not be copied as they will get optimized by imagemin
        copy: {
            dist: {
                files: [
                    {expand: true,
                        cwd: './',
                        src: ['data/**',
                                'docs/**',
                                'modules/**',
                                'resources/images/**',
                                'resources/schematron/**',
                                'resources/xsd/**',
                                'resources/xsl/**',
                                'templates/**',
                                'content/**',
                                'test/**',
                                '*.xconf','*.xql', '*.xml', '*.txt', '*.ico', '*.html'
                        ],
                        dest: 'dist/'},
                    {expand: true,
                        cwd: './',
                        flatten: true,
                        src: ['bower_components/font-awesome/fonts/**'],
                        dest: 'dist/resources/fonts/',
                        filter: 'isFile'
                    }
                ]
            }
        },

        /*
         optimizes images for the web. Currently only .png files are considered. This might be extended later.
         */
        imagemin: {
            png: {
                options: {
                    optimizationLevel: 7
                },
                files: [
                    {
                        // Set to true to enable the following options…
                        expand: true,
                        // cwd is 'current working directory'
                        cwd: './resources/img/',
                        src: ['**/*.png'],
                        // Could also match cwd line above. i.e. project-directory/img/
                        dest: 'dist/resources/img/',
                        ext: '.png'
                    }
                ]
            }
        },

        /*
         minifies the file 'resources/js/app.js'. Creates a minified version 'app.min.js'. Using a fixed and unconfigurable
         name makes substitution in html page easier - see build comments at the end of html files.
         */
        uglify: {
            dist: {
                files: {
                    'resources/js/app.min.js': [
                        'resources/js/app.js'
                    ]
                }
            }
        },

        /*
         concatenates all minified JavaScript files into one. Destination file will be app.min.js
         */
        concat: {
            options: {
                // define a string to put between each file in the concatenated output
                stripBanners: true
            },
            dist: {
                // the files to concatenate - use explicit filenames here to ensure proper order
                // puts app.js at the end.
                src: [
                    'bower_components/jquery/dist/jquery.min.js',
                    'bower_components/bootstrap/dist/js/bootstrap.min.js',
                    'bower_components/snap.svg/dist/snap.svg-min.js',
                    'resources/js/app.min.js'],
                // the location of the resulting JS file
                dest: 'dist/resources/js/app.min.js'
            }
        },

        less: {
            development: {
                options:{
                    strictImports:true
                },
                files: {
                    "resources/css/styles.css": "resources/css/styles.less"
                }
            },
            production: {
                options:{
                    strictImports:true
                },
                files: {
                    "resources/css/styles.css": "resources/css/styles.less"
                }
            }
        },

        /*
         removes unused CSS rules by investigating the imports of html files. Used to strip down e.g. bootstrap to
         the actual used amount of rules.
         */
        uncss: {
            options: {
                ignore: ['.collapsing', '.navbar-collapse.collapse', '.collapse.in'],
                flatten: true
            },
            dist: {
                src: ['./styleguide.html'],
                dest: 'resources/css/tidy.css'
            }
        },

        /*
        minify the already cleaned up CSS files
        */
        cssmin: {
            dist: {
                options: {
                    compatibility: 'ie8',
                    keepSpecialComments: 0,
                    report: 'min'
                },
                files: {
                    'dist/resources/css/app.min.css': '<%= uncss.dist.dest %>'
                }
            }
        },

        /*
         Gives statistical information about CSS compression results
         */
        compare_size: {
            files: [
                'resources/css/*.css',
                'dist/resources/css/app.min.css'
            ]
        },

        /*
        This task will replace CSS and JS imports in the main html file to point to the optimized versions instead
        of linking into 'components'
        */
        processhtml: {
            dist: {
                options: {
                    data: {
                        minifiedCss: '<link href="resources/css/app.min.css" type="text/css" rel="stylesheet"/>'
                    }
                },
                files: {
                    'dist/index.html': ['./index.html']
                }
            }
        },

        /*
         this task builds the actual .xar apps for deployment into eXistdb. zip:xar will create an unoptimized version while
         zip:production will use the optimized app found in the 'dist' directory.

         Note: here component files are cherry-picked - including the whole distribution is certainly more generic but bloats the resulting .xar too much
         */
        zip: {
            xar: {
                src: [
                    'collection.xconf',
                    '*.xml',
                    '*.xql',
                    '*.html',
                    'content/**',
                    'data/**',
                    'docs/**',
                    'modules/**',
                    'resources/**',
                    'templates/**',
                    'test/**',
                    'bower_components/animate.css/*',
                    'bower_components/bootstrap/dist/**',
                    'bower_components/font-awesome/css/**',
                    'bower_components/font-awesome/fonts/**',
                    'bower_components/jquery/dist/**',
                    'bower_components/snap.svg/dist/**'
                ],
                dest: 'build/<%=xar.name%>-<%=xar.version%>.xar'
            },
            production: {
                cwd: 'dist/',
                src: ['dist/**'],
                dest: 'build/<%=xar.name%>-<%=xar.version%>.min.xar'
            }
        },

        /*
         watches gruntfile itself and checks for problems
         */
        watch: {
            files: ['gruntfile.js'],
            tasks: ['jshint']
        }



    });

    /*
     */
    grunt.registerTask('default', [
        'replace',
        'less:development',
        'zip:xar'
    ]);

    grunt.registerTask('dist', [
        'clean',
        'replace',
        'copy',
        'imagemin',
        'uglify',
        'less:production',
        'concat',
        'uncss',
        'cssmin',
        'compare_size',
        'processhtml',
        'zip:production'
    ]);


};
