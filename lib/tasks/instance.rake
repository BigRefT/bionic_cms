# Redefined standard Rails tasks only in instance mode
unless Bionic.app?
  require 'rake/testtask'
  
  ENV['BIONIC_ENV_FILE'] = File.join(RAILS_ROOT, 'config', 'environment')
  
  [Dir["#{BIONIC_ROOT}/vendor/rails/railties/lib/tasks/*.rake"]].flatten.each do |rake|
    lines = IO.readlines(rake)
    lines.map! do |line|
      line.gsub!('RAILS_ROOT', 'BIONIC_ROOT') unless rake =~ /(misc|rspec|databases)\.rake$/
      case rake
      when /testing\.rake$/
        line.gsub!(/t.libs << (["'])/, 't.libs << \1#{BIONIC_ROOT}/')
        line.gsub!(/t\.pattern = (["'])/, 't.pattern = \1#{BIONIC_ROOT}/')
      when /databases\.rake$/
        line.gsub!(/(migrate|rollback)\((["'])/, '\1(\2#{BIONIC_ROOT}/')
        line.gsub!(/(run|new)\((:up|:down), (["'])db/, '\1(\2, \3#{BIONIC_ROOT}/db')
      end
      line
    end
    eval(lines.join("\n"), binding, rake)
  end
end