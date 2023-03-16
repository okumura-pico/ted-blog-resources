TARGET=template.json
BICEP=az bicep

all: $(TARGET)

$(TARGET): %.json: %.bicep
	$(BICEP) build --file $<

