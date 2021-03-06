require 'rubygems'
require 'templater'

module Rhosync
  extend Templater::Manifold
  extend Rhosync
  
  desc <<-DESC
    Rhosync generator
  DESC
  
  class BaseGenerator < Templater::Generator
    def class_name
      name.gsub('-', '_').camel_case
    end
    
    def underscore_name
      Rhosync.under_score(name)
    end

    def gem_version
      VERSION
    end 
    
    alias_method :module_name, :class_name
  end
  
  class AppGenerator < BaseGenerator
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'application')
    end
    
    desc <<-DESC
      Generates a new rhosync application.
      
      Required:
        name        - application name
    DESC
    
    first_argument :name, :required => true, :desc => "application name"
    
    template :configru do |template|
      require 'securerandom' rescue nil
      @secret = SecureRandom.hex(64) rescue '<changeme>'
      template.source = 'config.ru'
      template.destination = "#{name}/config.ru"
    end    
    
    template :settings do |template|
      template.source = 'settings/settings.yml'
      template.destination = "#{name}/settings/settings.yml"
    end
    
    template :license do |template|
      template.source = 'settings/license.key'
      template.destination = "#{name}/settings/license.key"
    end
    
    template :application do |template|
      template.source = 'application.rb'
      template.destination = "#{name}/application.rb"
    end
    
    template :rakefile do |template|
      template.source = 'Rakefile'
      template.destination = "#{name}/Rakefile"
    end
    
    template :gemfile do |template|
      template.source = 'Gemfile'
      template.destination = "#{name}/Gemfile"
    end
    
    template :spec_helper do |template|
      template.source = 'spec/spec_helper.rb'
      template.destination = "#{name}/spec/spec_helper.rb"
    end
  end
  
  class SourceGenerator < BaseGenerator
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'source')
    end

    desc <<-DESC
      Generates a new source adapter.
      
      Required:
        name        - source name(i.e. product)
    DESC

    first_argument :name, :required => true, :desc => "source name"

    template :source do |template|
      template.source = 'source_adapter.rb'
      template.destination = "sources/#{underscore_name}.rb"
      settings_file = File.join(@destination_root,'settings','settings.yml')
      settings = YAML.load_file(settings_file)
      settings[:sources] ||= {}
      settings[:sources][class_name] = {:poll_interval => 300}
      File.open(settings_file, 'w' ) do |file|
        file.write "#Sources" + {:sources => settings[:sources]}.to_yaml[3..-1]
        envs = {}
        [:development,:test,:production].each do |env|
          envs[env] = settings[env]
        end
        file.write envs.to_yaml[3..-1]
      end
    end
    
    template :source_spec do |template|
      template.source = 'source_spec.rb'
      template.destination = "spec/sources/#{underscore_name}_spec.rb"
    end
  end
  
  add :app, AppGenerator
  add :source, SourceGenerator
end