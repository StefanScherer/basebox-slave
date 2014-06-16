module.exports = function(grunt) {
  grunt.initConfig({
    jenkins: {
      serverAddress: 'http://10.100.50.4:2200',
      pipelineDirectory: 'jenkins-configuration'
    }
  })
  grunt.loadNpmTasks('grunt-jenkins');
  grunt.registerTask('default', ['jenkins-list']);
};
