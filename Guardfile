$stdout.sync = true

require 'guard'
require 'guard/guard'
require 'rake-pipeline'

module ::Guard
  class RakePipeline < ::Guard::Guard
    def start
      UI.info "Guard::RakePipeline is running."
      run
    end

    def run_all
      run
    end

    def reload
      run
    end

    def run_on_change(paths)
      puts "change: #{paths.inspect}"
      run
    end

    private

      def run
        started = Time.now
        print 'Compiling ... '
        project.invoke_clean
        puts "done (#{(Time.now - started).round(2)}s)."
      end

      def project
        @project ||= Rake::Pipeline::Project.new('./Assetfile')
      end
  end
end

guard 'rake_pipeline' do
  watch %r(^(lib|spec)/.*\.coffee)
end


