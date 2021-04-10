set :user, "danbooru"
set :rails_env, "development"
server "ib-zathura", :roles => %w(web app db), :primary => true, :user => "danbooru"
