name = builder

bootstrap: .image

.image: Dockerfile
	docker build -t $(name) .
	touch $@
