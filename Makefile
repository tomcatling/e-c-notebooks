push:
	git add .
	git commit -m "$(msg)"
	git push origin
	git push codecommit

infrastructure:
	sh scripts/create_infrastructure.sh

image:
	sh scripts/build_image.sh

server:
	sh scripts/jupyterlab_remote.sh

local_server:
	sh scripts/jupyterlab_local.sh

job:
	sh scripts/run_job.sh "$(nbpath)"