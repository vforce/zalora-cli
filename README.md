Some useful commands to help zalora SHOP dev

* `git clone git@github.com:vforce/zalora-cli.git` into your home folder
* Install hub with `brew install hub`
* Install rvm with `gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \curl -sSL https://get.rvm.io | bash -s stable --ruby`. After that follow rvm's instruction to run `source...` command to start using rvm
* `cd zalora-cli`
* Install bundler using `gem install bundler`
* `bundle install`
* move file `env.sample` to `.env` and change the home directory to your environment's and change the settings in .env accordingly
* `ruby zalora.rb` to see help
* `ruby zalora.rb login_jira <khoa.dang@zalora.com>` to login into jira

What is can do so far:
* create minify branch, run minify, commit, push and give the commit hash ready to be deploy to staging
* create pr for a ticket, change status of a ticket and notify reviewer
* generate, remove alice's config file and run generate in docker
