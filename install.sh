PASSWORD=$1

gem build pod-pipeline.gemspec -o pod-pipeline.gem
sudo -S gem install pod-pipeline.gem << EOF
${PASSWORD}
EOF