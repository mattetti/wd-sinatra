describe_service "/hello_world" do |service|
  service.formats   :json, :xml
  service.http_verb :get
  service.disable_auth # on by default

  # DOCUMENTATION
  service.documentation do |doc|
    doc.overall "Be polite and say hello"
    doc.example "<code>curl -I 'http://localhost:9292/hello_world?name=Matt'</code>"
  end

  # INPUT
  service.params do |p|
    p.string  :name, :default => 'World'
    p.namespace :user do |user|
      user.integer :id, :required => :true
    end
  end

  # OUTPUT
  service.response do |response|
    response.object do |obj|
      obj.string :message, :doc => "The greeting message sent back. Defaults to 'World'"
      obj.datetime :at, :doc => "The timestamp of when the message was dispatched"
    end
  end

  # ACTION/IMPLEMENTATION
  service.implementation do
    data = {:message => "Hello #{params[:name]}", :at => Time.now}
    case env["wd.format"]
    when :json
      data.to_json
    when :xml
      # data.to_xml # serialize to xml
    end
  end

end
