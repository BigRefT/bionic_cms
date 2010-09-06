require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'bionic'

PKG_NAME = 'bionic'
PKG_VERSION = Bionic::Version.to_s
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME  = ENV['RELEASE_NAME'] || PKG_VERSION
RELEASE_NOTES = ENV['RELEASE_NOTES'] ? " -n #{ENV['RELEASE_NOTES']}" : ''
RELEASE_CHANGES = ENV['RELEASE_CHANGES'] ? " -a #{ENV['RELEASE_CHANGES']}" : ''

RDOC_TITLE = "Bionic -- Bigger, Faster, Stonger"
RDOC_EXTRAS = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]

namespace 'bionic' do
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.author = "Bionic CMS dev team"
    s.email = "bionic@bioniccms.com"
    s.summary = 'Bigger, Faster, Stonger... Bionic CMS!'
    s.description = "Bionic is an open source content management system designed for developers and web designers. It is influenced heavily by Radiant, but expands upon the no-fluff that the Radiant team adopted."
    s.homepage = 'http://www.bioniccms.com'
    s.platform = Gem::Platform::RUBY
    s.bindir = 'bin'
    s.executables = (Dir['bin/*'] + Dir['scripts/*']).map { |file| File.basename(file) } 
    s.add_dependency 'rake', '>= 0.8.3'
    s.add_dependency 'rack', '~> 1.1.0' # No longer bundled in actionpack
    s.has_rdoc = true
    s.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
    rdoc_excludes = Dir["**"].reject { |f| !File.directory? f }
    rdoc_excludes.each do |e|
      s.rdoc_options << '--exclude' << e
    end
    s.extra_rdoc_files = RDOC_EXTRAS
    files = FileList['**/*']
    files.exclude '**/._*'
    files.exclude '**/*.rej'
    files.exclude '.git*'
    files.exclude /^cache/
    files.exclude 'config/database.yml'
    files.exclude 'db/*.db'
    files.exclude /^doc/
    files.exclude 'log/*.log'
    files.exclude 'log/*.pid'
    files.include 'log/.keep'
    files.exclude /^pkg/
    files.exclude /\btmp\b/
    files.exclude 'bionic.gemspec'
    # Read .gitignore from plugins and exclude those files
    Dir['vendor/plugins/*/.gitignore'].each do |gi|
      dirname = File.dirname(gi)
      File.readlines(gi).each do |i|
        files.exclude "#{dirname}/**/#{i}"
      end
    end
    # Read .gitignore from gems and exclude those files
    Dir['vendor/gems/*/.gitignore'].each do |gi|
      dirname = File.dirname(gi)
      File.readlines(gi).each do |i|
        files.exclude "#{dirname}/**/#{i}"
      end
    end
    s.files = files.to_a
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end

  task :gemspec do
    File.open('bionic.gemspec', 'w') {|f| f.write spec.to_ruby }
  end

  namespace :gem do
    desc "Uninstall Gem"
    task :uninstall do
      sudo = "sudo " if ENV['SUDO'] == 'true'
      sh "#{sudo}gem uninstall #{PKG_NAME}" rescue nil
    end

    desc "Build and install Gem from source"
    task :install => [:gemspec, :package, :uninstall] do
      chdir("#{BIONIC_ROOT}/pkg") do
        latest = Dir["#{PKG_NAME}-*.gem"].last
        sudo = "sudo " if ENV['SUDO'] == 'true'
        sh "#{sudo}gem install #{latest}"
      end
    end
  end
end
