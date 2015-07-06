
REPO_NAME	:= s3-repository
REPO_DESC	:= Amazon S3 Repository
REPO_DIR	:= $(REPO_NAME)
REPO_SUB	:= el7
S3_BUCKET	:= $(REPO_NAME)
S3_REGION	:= ap-southeast-2
ARCHS		:= x86_64,noarch

.PHONY: clean configure deps repofile createrepo updaterepo sync copybuilds

define REPOFILE
[$(REPO_NAME)]
name=$(REPO_DESC) - $$basearch
baseurl=https://s3-$(S3_REGION).amazonaws.com/$(S3_BUCKET)/$(REPO_SUB)/$$basearch/
enabled=1
#gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-$(REPO_NAME)
gpgcheck=0
endef

deps:
	@yum -y install python-pip createrepo
	@pip install --upgrade s3cmd

configure:
	@{ [[ ! -e ~/.s3cfg ]] && s3cmd --configure ;} \
		|| echo "Pre-existing configuration found. Skipping."

export REPOFILE
repofile:
	@echo "$$REPOFILE" > $(REPO_NAME).repo

$(REPO_NAME).spec:
	@cp repository.spec $(REPO_NAME).spec

$(REPO_DIR)/$(REPO_SUB):
	@mkdir -p $(REPO_DIR)/$(REPO_SUB)/{$(ARCHS)}

$(REPO_DIR): $(REPO_DIR)/$(REPO_SUB)
	@if [ -z "$(REPO_SUB)" ]; then mkdir -p $(REPO_DIR)/{$(ARCHS)}; fi

createrepo: $(REPO_DIR)
	@for a in $(REPO_DIR)/$(REPO_SUB)/{$(ARCHS)} ; \
		do createrepo -v --deltas $$a/ ; done

updaterepo: $(REPO_DIR)
	@for a in $(REPO_DIR)/$(REPO_SUB)/{$(ARCHS)} ; \
		do createrepo -v --update --deltas $$a/ ; done

sync: $(REPO_DIR)
	@s3cmd -P sync $(REPO_DIR)/ s3://$(S3_BUCKET)/ --delete-removed

get: $(REPO_DIR)
	@cd $(REPO_DIR) && \
		s3cmd -P get s3://$(S3_BUCKET)/ --recursive

copybuilds: $(REPO_DIR)
	@for a in {$(ARCHS)}; \
		do { [[ -d ~/rpmbuild/RPMS/$$a ]] \
			&& find ~/rpmbuild/RPMS/$$a -name "*.rpm" \
				-exec cp {} $(REPO_DIR)/$(REPO_SUB)/$$a/. \; ; } || echo -n "" ; done

clean:
	rm -rf $(REPO_DIR)
