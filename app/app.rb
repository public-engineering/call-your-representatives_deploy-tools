require 'httparty'
require 'sinatra'
require 'json'
require 'twilio-ruby'
require './environment'
require 'thin'
require 'faker'


class Slack
    include HTTParty
    base_uri 'https://hooks.slack.com'
    default_params :output => 'json'
    format :json
end

class CallYourReps < Sinatra::Base
  use Rack::Session::Cookie
  set :environment, :production
  ENV['RACK_ENV'] = "production"
  default_client = Faker::HeyArnold.character.downcase.tr(" ", "_").tr(".","_")

  get '/' do
      erb :index
  end

  post '/reps' do
      loc = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{params[:zip_code]}&sensor=true")
      loc_json = JSON.parse(loc.body)['results']
          location_data = loc_json[0]['formatted_address'].to_s
          erb :call, :locals => { :zip_code => params[:zip_code], :city_name => location_data }
  end

  get '/call/:rep_id' do
      # put your own credentials here - from twilio.com/user/account
      account_sid = ENV['twilio_sid']
      auth_token = ENV['twilio_token']
      twilio_phone = ENV['numbers_outbound']

      capability = Twilio::Util::Capability.new account_sid, auth_token

      capability.allow_client_outgoing "#{ENV['outgoing_token']}"
      capability.allow_client_incoming default_client
      token = capability.generate

      erb :dialer, :locals => { :token => token, :rep_id => params['rep_id'] }
  end

  caller_id = "+1#{ENV['numbers_outbound']}"

  post '/voice' do
      number = params[:PhoneNumber] || default_client
      response = Twilio::TwiML::Response.new do |r|

          r.Dial :callerId => caller_id do |d|
              # Test to see if the PhoneNumber is a number, or a Client ID. In
              # this case, we detect a Client ID by the presence of non-numbers
              # in the PhoneNumber parameter.
              if /^[\d\+\-\(\) ]+$/.match(number)
                  d.Number(CGI::escapeHTML number)
              else
                  d.Client number
              end
          end
      end
      response.text
  end

end
run CallYourReps.run!
