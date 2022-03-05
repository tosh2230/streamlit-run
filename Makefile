host_port = 8551
container_port = 8501
version = latest
src_dir = _default
config_dir = .streamlit

build-local:
	@docker build -t streamlit_run_default:${version} ./_default

run-local:
	@docker run --rm \
		--name streamlit-run \
		-e PORT=${container_port} \
		-p ${host_port}:${container_port} \
		-v $(CURDIR)/${src_dir}:/app \
		-v $(CURDIR)/${config_dir}:/root/${config_dir} \
		streamlit_run_default | sed -e "s/${container_port}/${host_port}/g"

build-gcr:
	@gcloud builds submit --tag gcr.io/${GCP_PROJECT}/streamlit_run_default ./_default
	# @gcloud builds submit --tag gcr.io/${GCP_PROJECT}/streamlit_run_backend01 ./backend01
	# @gcloud builds submit --tag gcr.io/${GCP_PROJECT}/streamlit_run_backend02 ./backend02

deploy:
	@gcloud run deploy streamlit-run-default --image gcr.io/${GOOGLE_CLOUD_PROJECT}/streamlit_run_default --region us-central1
