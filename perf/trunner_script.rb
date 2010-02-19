Trunner.config do |config|
  config.concurrency = 50
  config.iterations  = 100
end

@all_objects = "[{\"version\":3},{\"token\":\"%s\"},{\"count\":5},{\"progress_count\":0},{\"total_count\":5},{\"insert\":{\"435\":{\"brand\":\"\",\"name\":\"hello\",\"price\":\"\",\"created_at\":\"2010-02-17T12:54:15Z\",\"quantity\":\"\",\"updated_at\":\"2010-02-17T12:54:15Z\",\"sku\":\"\"},\"438\":{\"name\":\"2000\",\"price\":\"414.2\",\"brand\":\"Mokia\",\"created_at\":\"2010-02-18T13:20:33Z\",\"quantity\":\"5\",\"updated_at\":\"2010-02-18T13:20:33Z\",\"sku\":\"412\"},\"341\":{\"name\":\"Nexus One\",\"price\":\"$569.99\",\"brand\":\"Google\",\"created_at\":\"2010-01-12T01:40:57Z\",\"quantity\":\"9\",\"updated_at\":\"2010-02-01T18:29:53Z\",\"sku\":\"3\"},\"255\":{\"name\":\"Storm\",\"price\":\"$199.99\",\"brand\":\"BlackBerry\",\"created_at\":\"2009-11-14T09:48:23Z\",\"quantity\":\"2\",\"updated_at\":\"2010-01-19T17:20:07Z\",\"sku\":\"0233\"},\"246\":{\"price\":\"$199.99\",\"name\":\"iPhone\",\"brand\":\"Apple\",\"created_at\":\"2009-11-09T02:55:32Z\",\"quantity\":\"5\",\"updated_at\":\"2010-01-19T17:20:20Z\",\"sku\":\"55555\"}}}]"

Trunner.test do |session|
  @host = "http://rhosyncnew.staging.rhohub.com"
  
  session.post "#{@host}/apps/store/clientlogin", :content_type => :json do
    {:login => 'lars', :password => 'larspass'}.to_json
  end
  session.get "#{@host}/apps/store/clientcreate"
  @client_id = JSON.parse(session.last_response)['client']['client_id']
  session.get "#{@host}/apps/store" do
    {'source_name' => 'Product', 'client_id' => @client_id}
  end
  token = JSON.parse(session.last_response)[1]['token']
  session.verify(@all_objects % token, session.last_response)
  session.get "#{@host}/apps/store" do
    { 'source_name' => 'Product', 
      'client_id' => @client_id,
      'token' => token}
  end
end  
