DTBO := i2c-lcd-2004a-overlay.dtbo

all: $(DTBO)

$(DTBO): i2c-lcd-2004a-overlay.dts
	dtc -@ -I dts -O dtb -o $@ $<

clean:
	rm -f $(DTBO)
