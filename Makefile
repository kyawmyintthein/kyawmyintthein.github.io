
run:
	hugo server

deploy:
	hugo -d ../kyawmyintthein.github.io
	git add .
	git commit -m "release new changes"
	git push origin master