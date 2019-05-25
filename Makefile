domain = example.com

# Root CA
root-ca: root-ca-cert.pem

root-ca-key.pem:
	certtool --generate-privkey --outfile root-ca-key.pem --sec-param high

root-ca-cert.pem: root-ca-key.pem
	certtool --generate-self-signed --template root-ca.cfg \
	--load-privkey root-ca-key.pem --outfile root-ca-cert.pem

# Intermediate CA
intm-ca: intm-ca-cert.pem

intm-ca-key.pem:
	certtool --generate-privkey --outfile intm-ca-key.pem --sec-param medium

intm-ca-request.pem: intm-ca-key.pem
	certtool --generate-request --template intm-ca.cfg \
	--load-privkey intm-ca-key.pem --outfile intm-ca-request.pem

intm-ca-cert.pem: intm-ca-request.pem root-ca-cert.pem root-ca-key.pem
	certtool --generate-certificate \
	--template intm-ca.cfg --outfile intm-ca-cert.pem \
	--load-request intm-ca-request.pem \
	--load-ca-certificate root-ca-cert.pem --load-ca-privkey root-ca-key.pem

# User identity certificate
user-id-cert-key: user-id-csr user-id-cert

user-id-cert: user-id/$(name)/user-id-$(name).cfg \
	user-id/$(name)/user-id-$(name)-cert.pem \
	user-id/$(name)/user-id-$(name)-cert-chain.pem

user-id-csr: user-id/$(name)/user-id-$(name).cfg \
	user-id/$(name)/user-id-$(name)-key.pem \
	user-id/$(name)/user-id-$(name)-key-p8.pem \
	user-id/$(name)/user-id-$(name)-csr.pem

user-id/$(name)/user-id-$(name).cfg:
	mkdir -p user-id/$(name)
	sed -e 's/__name__/$(name)/g' user-id.cfg > user-id/$(name)/user-id-$(name).cfg

user-id/$(name)/user-id-$(name)-key.pem:
	mkdir -p user-id/$(name)
	certtool --generate-privkey --sec-param medium \
	--outfile user-id/$(name)/user-id-$(name)-key.pem

user-id/$(name)/user-id-$(name)-key-p8.pem: user-id/$(name)/user-id-$(name)-key.pem
	certtool --password='' --to-p8 \
	--load-privkey user-id/$(name)/user-id-$(name)-key.pem \
	--outfile user-id/$(name)/user-id-$(name)-key-p8.pem

user-id/$(name)/user-id-$(name)-csr.pem: user-id/$(name)/user-id-$(name).cfg
	certtool --generate-request --template user-id/$(name)/user-id-$(name).cfg \
	--load-privkey user-id/$(name)/user-id-$(name)-key.pem \
	--outfile user-id/$(name)/user-id-$(name)-csr.pem

user-id/$(name)/user-id-$(name)-cert.pem: user-id/$(name)/user-id-$(name)-csr.pem
	mkdir -p user-id/$(name)
	certtool --generate-certificate \
	--template user-id/$(name)/user-id-$(name).cfg \
	--outfile user-id/$(name)/user-id-$(name)-cert.pem \
	--load-request user-id/$(name)/user-id-$(name)-csr.pem \
	--load-ca-certificate intm-ca-cert.pem --load-ca-privkey intm-ca-key.pem

user-id/$(name)/user-id-$(name)-cert-chain.pem: user-id/$(name)/user-id-$(name)-cert.pem
	cat user-id/$(name)/user-id-$(name)-cert.pem \
		intm-ca-cert.pem \
		> user-id/$(name)/user-id-$(name)-cert-chain.pem

# Server or Service certificate
serv-cert: serv/$(name).$(domain)/serv-$(name).cfg \
	serv/$(name).$(domain)/serv-$(name)-cert.pem \
	serv/$(name).$(domain)/serv-$(name)-cert-chain.pem \
	serv/$(name).$(domain)/serv-$(name)-key.pem \
	serv/$(name).$(domain)/serv-$(name)-key-p8.pem

serv/$(name).$(domain)/serv-$(name).cfg:
	mkdir -p serv/$(name).$(domain)
	sed -e 's/__name__/$(name)/g' \
	-e 's/__domain__/$(domain)/g' serv.cfg \
	> serv/$(name).$(domain)/serv-$(name).cfg

serv/$(name).$(domain)/serv-$(name)-key.pem:
	mkdir -p serv/$(name).$(domain)
	certtool --generate-privkey --sec-param medium \
	--outfile serv/$(name).$(domain)/serv-$(name)-key.pem

serv/$(name).$(domain)/serv-$(name)-key-p8.pem: serv/$(name).$(domain)/serv-$(name)-key.pem
	certtool --password='' --to-p8 \
	--load-privkey serv/$(name).$(domain)/serv-$(name)-key.pem \
	--outfile serv/$(name).$(domain)/serv-$(name)-key-p8.pem

serv/$(name).$(domain)/serv-$(name)-cert.pem: serv/$(name).$(domain)/serv-$(name)-key.pem
	mkdir -p serv/$(name).$(domain)
	certtool --generate-certificate \
	--template serv/$(name).$(domain)/serv-$(name).cfg \
	--outfile serv/$(name).$(domain)/serv-$(name)-cert.pem \
	--load-privkey serv/$(name).$(domain)/serv-$(name)-key.pem \
	--load-ca-certificate intm-ca-cert.pem --load-ca-privkey intm-ca-key.pem

serv/$(name).$(domain)/serv-$(name)-cert-chain.pem: serv/$(name).$(domain)/serv-$(name)-cert.pem
	cat serv/$(name).$(domain)/serv-$(name)-cert.pem \
		intm-ca-cert.pem \
		> serv/$(name).$(domain)/serv-$(name)-cert-chain.pem

# Node identity certificate
node-id-cert: node-id/$(name).$(domain)/node-id-$(name).cfg \
	node-id/$(name).$(domain)/node-id-$(name)-cert.pem \
	node-id/$(name).$(domain)/node-id-$(name)-cert-chain.pem \
	node-id/$(name).$(domain)/node-id-$(name)-key.pem \
	node-id/$(name).$(domain)/node-id-$(name)-key-p8.pem

node-id/$(name).$(domain)/node-id-$(name).cfg:
	mkdir -p node-id/$(name).$(domain)
	sed -e 's/__name__/$(name)/g' \
	-e 's/__ip_address__/$(ip_address)/g' \
	-e 's/__domain__/$(domain)/g' node-id.cfg \
	> node-id/$(name).$(domain)/node-id-$(name).cfg

node-id/$(name).$(domain)/node-id-$(name)-key.pem:
	mkdir -p node-id/$(name).$(domain)
	certtool --generate-privkey --sec-param medium \
	--outfile node-id/$(name).$(domain)/node-id-$(name)-key.pem

node-id/$(name).$(domain)/node-id-$(name)-key-p8.pem: node-id/$(name).$(domain)/node-id-$(name)-key.pem
	certtool --password='' --to-p8 \
	--load-privkey node-id/$(name).$(domain)/node-id-$(name)-key.pem \
	--outfile node-id/$(name).$(domain)/node-id-$(name)-key-p8.pem

node-id/$(name).$(domain)/node-id-$(name)-cert.pem: node-id/$(name).$(domain)/node-id-$(name)-key.pem
	mkdir -p node-id/$(name).$(domain)
	certtool --generate-certificate \
	--template node-id/$(name).$(domain)/node-id-$(name).cfg \
	--outfile node-id/$(name).$(domain)/node-id-$(name)-cert.pem \
	--load-privkey node-id/$(name).$(domain)/node-id-$(name)-key.pem \
	--load-ca-certificate intm-ca-cert.pem --load-ca-privkey intm-ca-key.pem

node-id/$(name).$(domain)/node-id-$(name)-cert-chain.pem: node-id/$(name).$(domain)/node-id-$(name)-cert.pem
	cat node-id/$(name).$(domain)/node-id-$(name)-cert.pem \
		intm-ca-cert.pem \
		> node-id/$(name).$(domain)/node-id-$(name)-cert-chain.pem

# Clean all
clean:
	rm -f *.pem
