TARGET=windows-11-ja-image.json
BICEP=az bicep

all: $(TARGET)

$(TARGET): %.json: %.bicep
	$(BICEP) build --file $<

