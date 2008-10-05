require "rubygems"
require "rake"
require "rake/testtask"
class Rake::FileListTestTask < Rake::TestTask
  # Create the tasks defined by this task lib.
  def define
    lib_path = @libs.join(File::PATH_SEPARATOR)
    desc "Run tests" + (@name==:test ? "" : " for #{@name}")
    task @name do
      run_code = ''
      RakeFileUtils.verbose(@verbose) do
        run_code = File.dirname(__FILE__)+"/file_list_test_loader.rb"
        @ruby_opts.unshift( "-I#{lib_path}" )
        @ruby_opts.unshift( "-w" ) if @warning
        ruby @ruby_opts.join(" ") +
          " \"#{run_code}\" " +
          file_list.collect { |fn| "\"#{fn}\"" }.join(' ') +
          " #{option_list}"
      end
    end
    self
  end
end
