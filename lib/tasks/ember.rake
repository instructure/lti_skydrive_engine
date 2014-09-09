namespace :skydrive do
  namespace :ember do
    desc 'Build the ember application using the RAILS_ENV variable'
    task :build do
      require 'ember/source'

      puts 'building ember for production'
      FileUtils.cp Ember::Source.bundled_path_for('ember.min.js'), 'app/assets/javascripts/skydrive/vendor/ember.js'
      puts 'building ember'
      puts `ember build --out-file app/assets/javascripts/skydrive/ember_app.js`
      puts 'minifying application.js'
      rewrite_file('app/assets/javascripts/skydrive/ember_app.js') { |f| Uglifier.compile(f) }

      # if (Rails.env.production?)
      #   puts 'building ember for production'
      #   FileUtils.cp Ember::Source.bundled_path_for('ember.min.js'), 'public/javascripts/vendor/ember.js'
      #   puts 'building ember'
      #   puts `ember build`
      #   puts 'minifying application.js'
      #   rewrite_file('public/javascripts/application.js') { |f| Uglifier.compile(f) }
      # else
      #   puts 'building ember for development'
      #   FileUtils.cp Ember::Source.bundled_path_for('ember.js'), 'public/javascripts/vendor/ember.js'
      #   puts 'building ember'
      #   puts `ember build -d`
      # end
    end

    #This doesn't work at present because ember requires an older version of handlebars
    #The version required by the ember-source gem conflicts.
    #task :handlebars do
    #  require 'handlebars/source'
    #
    #  if(Rails.env.production?)
    #    puts 'building handlebars for production'
    #    FileUtils.cp Handlebars::Source.runtime_bundled_path, 'public/javascripts/vendor/handlebars.js'
    #  else
    #    puts 'building handlebars for development'
    #    FileUtils.cp Handlebars::Source.bundled_path, 'public/javascripts/vendor/handlebars.js'
    #  end
    #end

    def rewrite_file(file, &block)
      source = File.read(file)
      File.write(file, block.call(source))
    end
  end
end
