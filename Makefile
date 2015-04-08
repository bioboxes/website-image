name = builder

all: out/contribute.png

out/%.png: tmp/%.png
	cp $< $@

tmp/%.png: tmp/%.raw.png
	docker run --volume=$(shell pwd):/input:rw $(name) \
	pngquant \
	  --force \
	  --speed 1 \
          --quality=65-90 \
          --output /input/$@ \
	  /input/$^

tmp/contribute.raw.png: tmp/images.png
	docker run \
		--volume=$(shell pwd):/input:rw \
		$(name) \
	        convert -colors 255 -crop 2000x2000+0+0 +repage /input/$^ /input/$@

tmp/images.png: images.svg
	docker run \
		--volume=$(shell pwd):/input:rw \
		$(name) \
                inkscape --file=/input/$< --export-png=/input/$@ --export-area-page

bootstrap: .image Gemfile.lock
	mkdir -p tmp out

.image: Dockerfile
	docker build -t $(name) .
	touch $@

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -f tmp/* out/*
