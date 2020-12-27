firmware:
	SECRET_KEY_BASE=asjdflkjasdflkasjlk MIX_ENV=prod MIX_TARGET=hifiberry_rpi0 mix firmware

deploy: firmware
	MIX_TARGET=hifiberry_rpi0 MIX_ENV=prod ./upload.sh nerves-735e

burn:
	SECRET_KEY_BASE=asjdflkjasdflkasjlk MIX_TARGET=hifiberry_rpi0 MIX_ENV=prod mix burn
