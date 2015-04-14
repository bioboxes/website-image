name = builder

objects = out/contribute.png

all: $(objects)

########################################
#
# Deploy image files to S3
#
########################################

deploy:
	bundle exec ./plumbing/push-to-s3 $(shell cat VERSION) $(objects)

out/%.png: tmp/%.png
	cp $< $@

########################################
#
# Build image files
#
########################################

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

########################################
#
# Bootstrap the project resources
#
########################################

bootstrap: .image Gemfile.lock
	mkdir -p tmp out

.image: Dockerfile
	docker build -t $(name) .
	touch $@

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -f tmp/* out/*
