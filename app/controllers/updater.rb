include AbiquoUpdater

Karin.controllers :updater do
  
  get :index, :map => "/updater" do
    render 'updater/index.liquid'
  end

  post :update, :map => "/update" do
    puts request.params.inspect
    if request.params['filename'].length != 0
      extract_from_localfile request.params['filename']
    else
      extract_from_url request.params['url']
    end

    do_upgrade
    clean_upgrade_data
    
    render 'updater/updated.liquid'
  end

end