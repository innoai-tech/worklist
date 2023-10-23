include hack/dotenv.mk

export KEYSTORE = ${PWD}/.secrets/${KEYSTORE_NAME}

gen.keystore:
	mkdir -p .secrets
	keytool \
		-genkey \
		-noprompt \
		-keyalg RSA \
		-keysize 2048 \
		-validity 10000 \
		-dname "CN=Null, OU=Null, O=Null, L=Null, S=Null, C=Null" \
		-keystore .secrets/${KEYSTORE_NAME} \
		-alias ${KEYSTORE_ALIAS} \
		-storepass ${KEYSTORE_PASS} \
		-keypass ${KEYSTORE_PASS}