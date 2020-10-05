firmware:
	SECRET_KEY_BASE=asjdflkjasdflkasjlk MIX_ENV=prod MIX_TARGET=hifiberry_rpi0 mix firmware

deploy: firmware
	./upload.sh nerves-735e
