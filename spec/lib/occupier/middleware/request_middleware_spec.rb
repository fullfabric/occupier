describe Occupier::RequestMiddleware do

  let!( :tenant ) { "tbs" }

  let!(:app)    { double("Rack app").as_null_object }
  let (:env)    { { 'HTTP_HOST' => "abc.example.com", 'rack.url_scheme' => "https", "rack.input" => "", "PATH_INFO" => "/profiles/1" } }

  it "extracts tenant name from header" do
    env.merge!({ "FF-Tenant" => tenant })

    expect(app).to receive(:call).with(tenant_defined_as(tenant))
    Occupier::RequestMiddleware.new(app).call(env)
  end

  it "extracts tenant name from params" do
    env.merge!({ "QUERY_STRING" => "tenant=#{tenant}" })

    expect(app).to receive(:call).with(tenant_defined_as(tenant))
    Occupier::RequestMiddleware.new(app).call env
  end

  it "extracts tenant name from cookie" do
    env.merge!( { "HTTP_COOKIE" => "tenant=#{tenant}" } )

    expect(app).to receive(:call).with(tenant_defined_as(tenant))
    Occupier::RequestMiddleware.new(app).call env
  end

end
