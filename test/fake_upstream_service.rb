require 'sinatra/base'

class FakeUpstreamService < Sinatra::Base
  get '/production/tree/:name' do

    filename = Rails.root.join "test/fixtures/trees/#{params['name']}.json" 

    if File.exists?(filename)

      content_type :json
      status 200
      File.open(filename, 'r').read

    elsif params['name'] == 'derper'

      status 500
      "Internal derper error. Nobody has been notified."

    else

      status 404

    end

  end

end
