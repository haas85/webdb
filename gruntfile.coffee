module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    meta:
      file   : 'webdb'
      package : "package",
      temp   : "build",
      banner : """
        /* <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("m/d/yyyy") %>
           <%= pkg.homepage %>
           Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %> - Licensed <%= _.pluck(pkg.license, "type").join(", ") %> */

        """
    # =========================================================================
    source:
      coffee: [
            "src/**.coffee"
          ]


    # =========================================================================
    coffee:
      core: files: '<%=meta.temp%>/<%=meta.file%>.debug.js': '<%=meta.temp%>/<%=meta.file%>.coffee'
      core_debug: files: '<%=meta.package%>/<%=meta.file%>.debug.js': '<%=meta.temp%>/<%=meta.file%>.coffee'

    concat:
      modules:
        src: "<%= source.coffee %>",  dest: "<%=meta.temp%>/<%=meta.file%>.coffee"

    uglify:
      options: compress: false, banner: "<%= meta.banner %>"
      engine: files: '<%=meta.package%>/<%=meta.file%>.js': '<%=meta.temp%>/<%=meta.file%>.debug.js'

    watch:
      coffee:
        files: ["<%= source.coffee %>"]
        tasks: ["concat:modules", "coffee:core", "coffee:core_debug", "uglify:engine"]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"

  grunt.registerTask "default", ["concat", "coffee", "uglify"]