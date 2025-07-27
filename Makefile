
run:
	hugo server --disableFastRender

build:
	hugo --minify

clean:
	rm -rf public/

# Local development with drafts
dev:
	hugo server --buildDrafts --buildFuture --disableFastRender

# Deploy using GitHub Actions (manual trigger)
deploy:
	git add .
	git commit -m "Update content and deploy"
	git push origin master