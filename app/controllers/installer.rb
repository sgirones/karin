Karin.controllers :installer do
  COMPONENTS = [
        {'id' => 'abiquo-kvm',
          'name' => 'Abiquo KVM',
          'params' => ['abiquo-kvm-nfs-path', 'abiquo-kvm-rs-ip']},
        {'id' => 'abiquo-server',
          'name' => 'Abiquo Server',
          'params' => ['test']},
        {'id' => 'abiquo-remoteservices',
          'name' => 'Abiquo Remote Services',
          'params' => ['test']},
        {'id' => 'abiquo-v2v',
          'name' => 'Abiquo V2V',
          'params' => ['test']}
      ]
  get :index, :map => "/installer" do
    render 'installer/index.liquid', :locals => {:components => COMPONENTS}
  end

  post :configure, :map => "/configure" do

    comps_to_config = []
    
    for comp in COMPONENTS
      if request.params.include? comp['id']
        comps_to_config.push comp
      end
    end

    render 'installer/configure.liquid', :locals => {:components => comps_to_config}
  end

  post :install, :map => "/install" do
    installed_comps = []

    installer = AbiquoInstaller.new

    for comp in COMPONENTS
      if request.params.include? comp['params'][0]
        installer.install_component comp, request.params
        installed_comps.push comp
      end
    end

    render 'installer/install.liquid', :locals => {:components => installed_comps}
  end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end

  
end
