
run:
	hugo server

build:
	hugo -d ../kyawmyintthein.github.io

deploy:
	hugo -d ../kyawmyintthein.github.io
	git add .
	git commit -m "release new changes"
	git push origin master