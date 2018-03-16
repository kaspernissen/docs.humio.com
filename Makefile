clean:
	rm -rf public

public:
	hugo
	docker build --tag="humio/docs:latest" .