name = builder

tmp/images.png: images.svg
	docker run \
		--volume=$(shell pwd):/input:rw \
		$(name) \
                inkscape --file=/input/$< --export-png=/input/$@ --export-area-page

bootstrap: .image
	mkdir -p tmp

.image: Dockerfile
	docker build -t $(name) .
	touch $@
