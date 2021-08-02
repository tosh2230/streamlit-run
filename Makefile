host_port = 8551
container_port = 8501
version = latest

build-local:
	@docker build -t streamlit-run:${version} .

build-gcr:
	@gcloud builds submit --tag gcr.io/${GCP_PROJECT}/streamlit_run

run-local:
	@docker run --rm \
		--name streamlit-run \
		-e PORT=${container_port} \
		-p ${host_port}:${container_port} \
		streamlit-run | sed -e "s/${container_port}/${host_port}/g"

run-test:
	@docker run --rm \
		--name streamlit-run \
		-e PORT=${container_port} \
		-p ${host_port}:${container_port} \
		gcr.io/alert-tine-289008/streamlit_run | sed -e "s/${container_port}/${host_port}/g"
