build: TemaLexer.class Main.class

TemaLexer.class:
	jflex tema.flex

Main.class:
	javac *.java

run: Main.class
	java Main

clean:
	rm *.class TemaLexer.java
