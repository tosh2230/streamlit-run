host_port = 8900
container_port = 9090
version = latest

build:
	docker build -t streamlit-run:${version} .
run:
	docker run --rm --name streamlit-run -e PORT=${container_port} -p ${host_port}:${container_port} streamlit-run | sed -e "s/${container_port}/${host_port}/g"
