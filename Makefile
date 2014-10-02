.PHONY: install check-installed deploy

install: check-installed
	ansible-playbook provisioning/playbook.yml -v --connection=local \
		--inventory-file=provisioning/ansible_hosts \
		--extra-vars "hosts=localhost app_host=urltimeline.local app_path=$(CURDIR)"

check-installed:
	test ! -f /etc/nginx/sites-enabled/urltimeline.conf
