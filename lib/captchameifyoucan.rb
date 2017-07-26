require "captchameifyoucan/version"
require 'commander'
require 'mechanize'
require 'base64'
require 'rtesseract'
require 'rmagick'

module Captchameifyoucan
  # Your code goes here...
  class CaptchameifyoucanApplication
    include Commander::Methods
    include Magick

    def run
      program :name, 'Captchameifyoucan'
      program :version, Captchameifyoucan::VERSION
      program :description, 'Captchameifyoucan.'

      command :decode do |c|
        c.syntax = 'captchameifyoucan decode'
        c.description = 'Generate incremental word list'
        c.option '-u', '--url SIZE', String, 'Set min size'
        c.action do |args, options|
          options.default \
  				      :url => "http://challenge01.root-me.org/programmation/ch8/"

          agent = Mechanize.new
          page = agent.get options.url
          captcha = page.search("img")
          image = captcha.first.attributes["src"].value()

          regex = /\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m

          data_uri_parts = image.match(regex) || []
          extension = MIME::Types[data_uri_parts[1]].first.preferred_extension
          file_name = "captcha.#{extension}"

          File.open(file_name, 'wb') do|f|
            f.write(Base64.decode64(data_uri_parts[2]))
          end

          whitelist = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten.join('')
          image = RTesseract.new(file_name, lang: 'eng') do |img|
            img = img.white_threshold(245).median(2)

          end
          p image.to_s_without_spaces # Getting the value
        end
      end
      run!
    end
  end


  def self.run()
    CaptchameifyoucanApplication.new.run
  end
end
