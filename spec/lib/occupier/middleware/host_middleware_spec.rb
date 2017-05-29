describe Occupier::HostMiddleware do

  let!( :tenant ) { "tbs" }

  let!(:app)    { double("Rack app").as_null_object }
  let (:env)    { { 'HTTP_HOST' => "abc.example.com", 'rack.url_scheme' => "https", "rack.input" => "", "PATH_INFO" => "/profiles/1" } }

  it "extracts name from host" do
    expect(app).to receive(:call).with(tenant_defined_as("abc"))
    Occupier::HostMiddleware.new(app).call(env)
  end

end
