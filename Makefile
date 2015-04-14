name   = builder
docker = docker run --volume=$(shell pwd):/input:rw $(name)

all: out/contribute.png

out/%.png: tmp/%.png
	cp $< $@

tmp/%.png: tmp/%.raw.png
	$(docker) pngquant \
	  --force \
	  --speed 1 \
          --quality=65-90 \
          --output /input/$@ \
	  /input/$^

tmp/%.raw.png: tmp/images.png
	$(docker) convert \
		-colors 255 \
		-crop $(shell grep $% dimensions.tab | cut -f 2) \
		+repage \
		/input/$< \
		/input/$@

tmp/images.png: images.svg
	$(docker) inkscape \
		--file=/input/$< \
		--export-png=/input/$@ \
		--export-area-page

bootstrap: .image Gemfile.lock
	mkdir -p tmp out

.image: Dockerfile
	docker build -t $(name) .
	touch $@

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -f tmp/* out/*
