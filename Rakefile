require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'test/file_list_test_task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the multidb_tester plugin.'
Rake::FileListTestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the multidb_tester plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MultidbTester'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
