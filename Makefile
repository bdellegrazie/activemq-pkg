NAME:=apache-activemq
VERSION:=5.13.3
SOURCE1:=$(NAME)-$(VERSION)-bin.tar.gz
SOURCE2:=activemq-$(VERSION).rar
ARCH:=native
ITERATION:=1
BUILD_DIR:=build

.PHONY: deb deb-clean rpm rpm-clean clean deps deps-clean source-clean source-expand packages

all: packages

deps-clean:
	rm -f *.tar.gz

deb-clean:
	rm -f *.deb

rpm-clean:
	rm -f *.rpm

clean: deb-clean rpm-clean source-clean

dist-clean: clean deps-clean

$(SOURCE1):
	wget --timestamping -c http://archive.apache.org/dist/activemq/$(VERSION)/$(SOURCE1)

$(SOURCE2):
	wget --timestamping -c http://repo1.maven.org/maven2/org/apache/activemq/activemq-rar/$(VERSION)/activemq-rar-$(VERSION).rar

deps: $(SOURCE1) $(SOURCE2)

source-clean:
	rm -rf $(BUILD_DIR)/*

source-expand: $(SOURCE1)
	mkdir -p $(BUILD_DIR)
	tar -xzf $(SOURCE1) -C $(BUILD_DIR)

deb: deb-clean source-expand $(SOURCE2)
	mkdir -p $(BUILD_DIR)/var/log/activemq
	fpm -t deb\
 -s dir\
 --name $(NAME)\
 --license "Apache License v2.0"\
 --vendor "brett.dellegrazie@indigoblue.co.uk"\
 --version $(VERSION)\
 --iteration $(ITERATION)\
 --category misc\
 --architecture $(ARCH)\
 --description 'Apache ActiveMQ'\
 --url http://activemq.apache.org/\
 --depends java8-runtime-headless\
 --directories /var/log/activemq\
 --deb-init $(BUILD_DIR)/$(NAME)-$(VERSION)/bin/linux-x86-64/activemq\
 --deb-default deb/activemq.default\
 --template-scripts\
 --after-install deb/after-install.sh\
 --after-remove deb/after-remove.sh\
 --before-remove deb/before-remove.sh\
 $(SOURCE2)=/opt/activemq/\
 $(BUILD_DIR)/var/log/activemq/=/var/log/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/bin=/opt/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/conf/=/etc/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/data=/opt/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/docs/=/usr/share/doc/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/lib=/opt/activemq\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/webapps=/opt/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/activemq-all-$(VERSION).jar=/opt/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/LICENSE=/usr/share/doc/activemq/\
 $(BUILD_DIR)/$(NAME)-$(VERSION)/README.txt=/usr/share/doc/activemq/

rpm: rpm-clean $(SOURCE1) $(SOURCE2)
	mkdir -p $(BUILD_DIR)/BUILD
	mkdir -p $(BUILD_DIR)/BUILDROOT
	mkdir -p $(BUILD_DIR)/RPMS
	rpmbuild -bb -D'VERSION $(VERSION)'\
 -D'ITERATION $(ITERATION)'\
 -D'_builddir $(PWD)/$(BUILD_DIR)/BUILD'\
 -D'_rpmdir   $(PWD)/$(BUILD_DIR)/RPMS'\
 -D'_sourcedir $(PWD)'\
 -D'_buildrootdir $(PWD)/$(BUILD_DIR)/BUILDROOT'\
 rpm/activemq-bin.spec
	mv $(BUILD_DIR)/RPMS/$(shell uname -m)/*.rpm .

packages: deb rpm

clean: deb-clean rpm-clean

dist-clean: clean deps-clean

