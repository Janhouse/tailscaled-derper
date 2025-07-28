# make docker image

image:
	docker compose build --pull --progress=plain derp && docker compose push derp
