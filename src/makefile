#Executable
EXECUTABLE=coregtkgen

#Sources
SOURCES=main.m XMLReader/XMLReader.m GIR/GIRApi.m GIR/GIRArray.m GIR/GIRBase.m GIR/GIRClass.m GIR/GIRConstant.m GIR/GIRConstructor.m GIR/GIRDoc.m GIR/GIREnumeration.m GIR/GIRField.m GIR/GIRFunction.m GIR/GIRImplements.m GIR/GIRInterface.m GIR/GIRParameter.m GIR/GIRProperty.m GIR/GIRMember.m GIR/GIRMethod.m GIR/GIRNamespace.m GIR/GIRPrerequisite.m GIR/GIRReturnValue.m GIR/GIRType.m GIR/GIRVarargs.m GIR/GIRVirtualMethod.m Generator/CGTKClassWriter.m Generator/CGTKClass.m Generator/CGTKMethod.m Generator/CGTKParameter.m Generator/CGTKUtil.m Gir2Objc.m

#Objects
OBJECTS=$(SOURCES:.m=.o)

#compiler
CC=gcc

#CFLAGS
CFLAGS=-c -Wall

#Objective-c specific flags
OBJCFLAGS=`gnustep-config --objc-flags` `pkg-config --cflags gtk+-3.0`

#Objective-c specific flags
MACOBJCFLAGS=-framework Foundation

#GNUstep dependencies
GNUSTEPDEPS=`gnustep-config --base-libs`

#GTK dependencies
GTKDEPS=`pkg-config --libs gtk+-3.0`

#Common flags
COMMONFLAGS=$(OBJCFLAGS) $(GNUSTEPDEPS) $(GTKDEPS)


#Targets

#Linux Target
linux: all

#Mac Target
mac: COMMONFLAGS=$(MACOBJCFLAGS) $(GTKDEPS)
mac: all

#Windows Target
windows: all

#All Target
all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) $(COMMONFLAGS) -o $@

%.o: %.m
	$(CC) $(CFLAGS) $(COMMONFLAGS) $< -o $@

clean: 
	rm -rf *.o *.d $(EXECUTABLE)
	rm -rf BaseClasses/*.o BaseClasses/*.d
	rm -rf Generator/*.o Generator/*.d
	rm -rf GIR/*.o GIR/*.d
	rm -rf XMLReader/*.o XMLReader/*.d
#Uncomment these if you want to also clean the generated source files
#	rm -rf Output/CoreGTK/*.h
#	rm -rf Output/CoreGTK/*.m
