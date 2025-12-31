.PHONY: all driver dts clean

all: driver dts

driver:
	$(MAKE) -C driver

dts:
	$(MAKE) -C dts

clean:
	$(MAKE) -C driver clean
	$(MAKE) -C dts clean
